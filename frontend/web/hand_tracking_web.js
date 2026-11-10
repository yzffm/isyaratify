/**
 * Isyaratify — Web Camera & MediaPipe Tasks Vision JS Adapter (ADR 0002)
 *
 * Berjalan sepenuhnya di perangkat browser pengguna (on-device).
 * Tidak ada frame gambar/video yang dikirim ke server.
 */
(function () {
  const MEDIAPIPE_VISION_CDN =
    'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/vision_bundle.mjs';
  const MEDIAPIPE_WASM_ROOT =
    'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/wasm';
  const HAND_LANDMARKER_MODEL_URL =
    'https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task';

  // Target ~12 FPS inferensi lokal untuk menjaga responsivitas UI
  const MIN_FRAME_INTERVAL_MS = 82;

  let visionModule = null;
  let handLandmarker = null;
  let mediaStream = null;
  let videoElement = null;
  let canvasElement = null;
  let rafId = null;
  let isProcessing = false;
  let lastInferenceTime = 0;

  function ensureContainerElements(containerId) {
    let container = document.getElementById(containerId);
    if (!container) {
      container = document.createElement('div');
      container.id = containerId;
      container.style.width = '100%';
      container.style.height = '100%';
      container.style.position = 'relative';
      container.style.overflow = 'hidden';
      container.style.backgroundColor = '#111827';
      container.style.borderRadius = '12px';
    } else {
      container.innerHTML = '';
    }

    videoElement = document.createElement('video');
    videoElement.setAttribute('playsinline', 'true');
    videoElement.setAttribute('autoplay', 'true');
    videoElement.muted = true;
    videoElement.style.width = '100%';
    videoElement.style.height = '100%';
    videoElement.style.objectFit = 'cover';
    videoElement.style.transform = 'scaleX(-1)';

    canvasElement = document.createElement('canvas');
    canvasElement.style.position = 'absolute';
    canvasElement.style.top = '0';
    canvasElement.style.left = '0';
    canvasElement.style.width = '100%';
    canvasElement.style.height = '100%';
    canvasElement.style.pointerEvents = 'none';
    canvasElement.style.transform = 'scaleX(-1)';

    container.appendChild(videoElement);
    container.appendChild(canvasElement);
    return container;
  }

  function drawHandOverlay(landmarksList) {
    if (!canvasElement || !videoElement) return;
    const width = videoElement.videoWidth || 640;
    const height = videoElement.videoHeight || 480;
    if (canvasElement.width !== width || canvasElement.height !== height) {
      canvasElement.width = width;
      canvasElement.height = height;
    }
    const ctx = canvasElement.getContext('2d');
    if (!ctx) return;
    ctx.clearRect(0, 0, width, height);

    if (!landmarksList || landmarksList.length === 0) return;

    const connections = [
      [0, 1], [1, 2], [2, 3], [3, 4],
      [0, 5], [5, 6], [6, 7], [7, 8],
      [5, 9], [9, 10], [10, 11], [11, 12],
      [9, 13], [13, 14], [14, 15], [15, 16],
      [13, 17], [17, 18], [18, 19], [19, 20], [0, 17]
    ];

    for (let h = 0; h < landmarksList.length; h++) {
      const pts = landmarksList[h];
      ctx.strokeStyle = h === 0 ? '#38BDF8' : '#34D399';
      ctx.lineWidth = 2.5;
      for (const [i, j] of connections) {
        if (pts[i] && pts[j]) {
          ctx.beginPath();
          ctx.moveTo(pts[i].x * width, pts[i].y * height);
          ctx.lineTo(pts[j].x * width, pts[j].y * height);
          ctx.stroke();
        }
      }
      ctx.fillStyle = '#FDE047';
      for (const pt of pts) {
        ctx.beginPath();
        ctx.arc(pt.x * width, pt.y * height, 3.5, 0, 2 * Math.PI);
        ctx.fill();
      }
    }
  }

  async function initialize(containerId) {
    if (!window.isSecureContext) {
      const err = new Error(
        'Kamera browser memerlukan konteks aman (HTTPS atau localhost).'
      );
      err.code = 'INSECURE_CONTEXT';
      throw err;
    }
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      const err = new Error('Browser ini tidak mendukung API kamera getUserMedia.');
      err.code = 'CAMERA_UNAVAILABLE';
      throw err;
    }

    ensureContainerElements(containerId);

    try {
      mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'user',
          width: { ideal: 640 },
          height: { ideal: 480 },
        },
        audio: false,
      });
    } catch (e) {
      const name = (e && e.name) || '';
      const err = new Error(
        name === 'NotAllowedError' || name === 'PermissionDeniedError'
          ? 'Izin akses kamera ditolak oleh pengguna.'
          : 'Kamera tidak ditemukan atau sedang dipakai aplikasi lain.'
      );
      err.code =
        name === 'NotAllowedError' || name === 'PermissionDeniedError'
          ? 'PERMISSION_DENIED'
          : 'CAMERA_UNAVAILABLE';
      throw err;
    }

    videoElement.srcObject = mediaStream;
    await videoElement.play();

    if (!handLandmarker) {
      try {
        if (!visionModule) {
          visionModule = await import(MEDIAPIPE_VISION_CDN);
        }
        const fileset = await visionModule.FilesetResolver.forVisionTasks(
          MEDIAPIPE_WASM_ROOT
        );
        handLandmarker = await visionModule.HandLandmarker.createFromOptions(
          fileset,
          {
            baseOptions: {
              modelAssetPath: HAND_LANDMARKER_MODEL_URL,
              delegate: 'GPU',
            },
            runningMode: 'VIDEO',
            numHands: 2,
            minHandDetectionConfidence: 0.5,
            minHandPresenceConfidence: 0.5,
            minTrackingConfidence: 0.5,
          }
        );
      } catch (e) {
        stopTracks();
        const err = new Error(
          'Gagal memuat MediaPipe Hand Landmarker: ' + (e && e.message ? e.message : e)
        );
        err.code = 'MODEL_LOAD_FAILED';
        throw err;
      }
    }
  }

  function start(onFrameJson, onError) {
    cancelLoop();
    lastInferenceTime = 0;

    function loop(now) {
      rafId = window.requestAnimationFrame(loop);
      if (isProcessing) return;
      if (now - lastInferenceTime < MIN_FRAME_INTERVAL_MS) return;
      if (!videoElement || videoElement.readyState < 2 || !handLandmarker) return;

      isProcessing = true;
      lastInferenceTime = now;

      try {
        const result = handLandmarker.detectForVideo(videoElement, now);
        const rawLandmarks = (result && result.landmarks) || [];
        const rawWorld = (result && result.worldLandmarks) || [];
        const rawHandedness = (result && result.handednesses) || [];

        drawHandOverlay(rawLandmarks);

        const hands = [];
        const count = Math.min(rawLandmarks.length, 2);
        for (let i = 0; i < count; i++) {
          const lm = rawLandmarks[i];
          if (!lm || lm.length !== 21) continue;

          const handMeta =
            rawHandedness[i] && rawHandedness[i][0] ? rawHandedness[i][0] : null;
          const rawCategory =
            handMeta && (handMeta.categoryName || handMeta.displayName)
              ? String(handMeta.categoryName || handMeta.displayName).toLowerCase()
              : i === 0
              ? 'left'
              : 'right';
          const handedness = rawCategory === 'right' ? 'right' : 'left';
          const score =
            handMeta && typeof handMeta.score === 'number' ? handMeta.score : null;

          const handObj = {
            handedness: handedness,
            landmarks: lm.map((p) => ({
              x: Number(p.x || 0),
              y: Number(p.y || 0),
              z: Number(p.z || 0),
            })),
          };
          if (score !== null && Number.isFinite(score)) {
            handObj.handednessScore = Math.max(0, Math.min(1, score));
          }
          if (rawWorld[i] && rawWorld[i].length === 21) {
            handObj.worldLandmarks = rawWorld[i].map((p) => ({
              x: Number(p.x || 0),
              y: Number(p.y || 0),
              z: Number(p.z || 0),
            }));
          }
          hands.push(handObj);
        }

        const payload = {
          timestamp: new Date().toISOString(),
          hands: hands,
          imageWidth: videoElement.videoWidth || 640,
          imageHeight: videoElement.videoHeight || 480,
          isMirrored: false,
        };
        if (typeof onFrameJson === 'function') {
          onFrameJson(JSON.stringify(payload));
        }
      } catch (err) {
        if (typeof onError === 'function') {
          onError(String(err && err.message ? err.message : err));
        }
      } finally {
        isProcessing = false;
      }
    }

    rafId = window.requestAnimationFrame(loop);
  }

  function cancelLoop() {
    if (rafId !== null) {
      window.cancelAnimationFrame(rafId);
      rafId = null;
    }
    isProcessing = false;
  }

  function stopTracks() {
    if (mediaStream) {
      const tracks = mediaStream.getTracks();
      for (const track of tracks) {
        try {
          track.stop();
        } catch (_) {}
      }
      mediaStream = null;
    }
    if (videoElement) {
      videoElement.srcObject = null;
    }
  }

  function stop() {
    cancelLoop();
    stopTracks();
  }

  function dispose() {
    stop();
    if (handLandmarker && typeof handLandmarker.close === 'function') {
      try {
        handLandmarker.close();
      } catch (_) {}
      handLandmarker = null;
    }
  }

  window.isyaratifyHandTracking = {
    ensureContainerElements: ensureContainerElements,
    initialize: initialize,
    start: start,
    stop: stop,
    dispose: dispose,
  };
})();
