import 'package:graphql_schema/graphql_schema.dart';
import 'package:test/test.dart';
import 'package:storage/stores.dart';

void main() {
  group('Query', () {
    test('single element', () async {
      final todoType = objectType('todo', fields: [
        field(
          'text',
          graphQLString,
          resolve: (obj, args) => obj.text,
        ),
        field(
          'completed',
          graphQLBoolean,
          resolve: (obj, args) => obj.completed,
        ),
      ]);

      final schema = graphQLSchema(
        queryType: objectType('api', fields: [
          field(
            'todos',
            listOf(todoType),
            resolve: (_, __) => [
                  Todo(
                    text: 'Clean your room!',
                    completed: false,
                  )
                ],
          ),
        ]),
      );

      final graphql = GraphQL(schema);
      final result = await graphql.parseAndExecute('{ todos { text } }');

      expect(result, {
        'todos': [
          {'text': 'Clean your room!'}
        ]
      });
    });
  });
}

class Todo {
  final String text;
  final bool completed;

  Todo({this.text, this.completed});
}
