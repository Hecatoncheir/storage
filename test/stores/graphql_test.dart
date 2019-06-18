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
            inputs: [GraphQLFieldInput('contains', graphQLString)],
            resolve: (_, inputs) {
              final todos = [
                Todo(
                  text: 'test',
                  completed: false,
                ),
                Todo(
                  text: 'text',
                  completed: false,
                )
              ];

              return todos
                  .where((todo) => todo.text.contains(inputs['contains']));
            },
          ),
        ]),
      );

      final graphql = GraphQL(schema);
      final result =
          await graphql.parseAndExecute('{ todos(contains: "test") { text } }');

      expect(result, {
        'todos': [
          {'text': 'test'}
        ]
      });

      final secondResult =
          await graphql.parseAndExecute('{ todos(contains: "text") { text } }');

      expect(secondResult, {
        'todos': [
          {'text': 'text'}
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
