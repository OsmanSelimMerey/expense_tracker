import 'package:expense_tracker/features/expenses/data/models/expense_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseDto API mapping', () {
    test('fromApiJson maps title to description and parses ISO date', () {
      final json = {
        'id': 'abc-123',
        'title': 'Lunch',
        'amount': 25.5,
        'date': '2026-07-22T10:00:00Z',
        'category': 'Food',
      };

      final dto = ExpenseDto.fromApiJson(json, 'user-1');

      expect(dto.id, 'abc-123');
      expect(dto.userId, 'user-1');
      expect(dto.description, 'Lunch');
      expect(dto.amount, 25.5);
      expect(dto.category, 'Food');
      expect(
        DateTime.fromMillisecondsSinceEpoch(dto.dateMilliseconds).toUtc(),
        DateTime.parse('2026-07-22T10:00:00Z').toUtc(),
      );
    });

    test('fromApiJson tolerates integer amount', () {
      final dto = ExpenseDto.fromApiJson({
        'id': '1',
        'title': 'x',
        'amount': 10,
        'date': '2026-01-01T00:00:00Z',
        'category': 'c',
      }, 'u');

      expect(dto.amount, 10.0);
    });

    test('toApiJson emits title/date/amount/category without userId', () {
      final dto = ExpenseDto(
        id: 'id-1',
        userId: 'user-1',
        amount: 12.0,
        category: 'Bills',
        dateMilliseconds:
            DateTime.parse('2026-03-05T08:30:00Z').millisecondsSinceEpoch,
        description: 'Electricity',
      );

      final json = dto.toApiJson();

      expect(json['title'], 'Electricity');
      expect(json['amount'], 12.0);
      expect(json['category'], 'Bills');
      expect(json.containsKey('userId'), isFalse);
      expect(DateTime.parse(json['date'] as String).toUtc(),
          DateTime.parse('2026-03-05T08:30:00Z').toUtc());
    });

    test('round-trips through entity', () {
      final dto = ExpenseDto.fromApiJson({
        'id': 'r1',
        'title': 'Coffee',
        'amount': 4.25,
        'date': '2026-07-22T10:00:00Z',
        'category': 'Food',
      }, 'user-9');

      final entity = dto.toEntity();
      final back = ExpenseDto.fromEntity(entity);

      expect(back.description, 'Coffee');
      expect(back.userId, 'user-9');
      expect(back.amount, 4.25);
    });
  });
}
