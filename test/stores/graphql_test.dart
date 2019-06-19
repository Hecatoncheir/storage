import 'package:graphql_schema/graphql_schema.dart';
import 'package:graphql_schema/graphql_schema.dart' as prefix0;
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

  group('Mutation', () {
    GraphQLObjectType todoType;

    GraphQLObjectType query;
    GraphQLObjectType mutation;

    List<Todo> todos;

    setUp(() {
      todos = <Todo>[];

      todoType = objectType('todo', fields: [
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

      query = objectType('TestQuery', fields: [
        field('todos', listOf(todoType),
            inputs: [GraphQLFieldInput('contains', graphQLString)],
            resolve: (_, inputs) =>
                todos.where((todo) => todo.text.contains(inputs['contains']))),
      ]);

      mutation = objectType(
        'TestMutation',
        fields: [
          field(
            'todo',
            todoType.nonNullable(),
            description: 'Modifies a todo in the database.',
            inputs: [
              GraphQLFieldInput('text', graphQLString.nonNullable()),
              GraphQLFieldInput('completed', graphQLBoolean.nonNullable()),
            ],
            resolve: (_, inputs) {
              final todo =
                  Todo(text: inputs['text'], completed: inputs['completed']);
              todos.add(todo);
              return todo;
            },
          ),
        ],
      );
    });

    test('create', () async {
      final schema = GraphQLSchema(queryType: query, mutationType: mutation);
      final graphQL = GraphQL(schema);
      const testMutation = '''
      mutation {
        todo(text: "First todo", completed: false) {
          text
          completed
        }
      }
      ''';

      expect(todos, isEmpty);
      final result = await graphQL.parseAndExecute(testMutation);
      expect(todos, isNotEmpty);
      expect(result['todo']['text'], equals('First todo'));
      expect(result['todo']['completed'], isFalse);
    });
  });
}

class Todo {
  final String text;
  final bool completed;

  Todo({this.text, this.completed});
}
