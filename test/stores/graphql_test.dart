import 'package:graphql_schema/graphql_schema.dart';
import 'package:test/test.dart';
import 'package:storage/stores.dart';

void main() {
  group('GraphQL', () {
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

    tearDown(() {
      todos.clear();
    });

    test('query', () async {
      todos.addAll([
        Todo(
          text: 'test',
          completed: false,
        ),
        Todo(
          text: 'text',
          completed: false,
        )
      ]);

      final schema = GraphQLSchema(queryType: query);
      final graphQL = GraphQL(schema);

      const todoContainsTestQuery = '''
      {
        todos(contains: "test") {
           text
        }
      }
      ''';

      final result = await graphQL.parseAndExecute(todoContainsTestQuery);

      expect(result, {
        'todos': [
          {'text': 'test'}
        ]
      });

      const todoContainsTextQuery = '''
      {
        todos(contains: "text") {
           text
        }
      }
      ''';

      final secondResult = await graphQL.parseAndExecute(todoContainsTextQuery);

      expect(secondResult, {
        'todos': [
          {'text': 'text'}
        ]
      });
    });

    test('mutation', () async {
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
