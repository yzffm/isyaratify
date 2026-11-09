import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/models/team_member_model.dart';

void main() {
  test('TeamMember.initial mengubah huruf pertama menjadi huruf besar', () {
    const member = TeamMember(name: 'yusuf', role: 'Project Lead');
    expect(member.initial, 'Y');
  });

  test('TeamMember.initial mengembalikan ? saat nama kosong', () {
    const member = TeamMember(name: '', role: 'Project Lead');
    expect(member.initial, '?');
  });
}
