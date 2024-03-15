// Ref. https://www.youtube.com/watch?v=s0lMwQjy2zM&t=6s
// https://www.youtube.com/watch?v=GwAnn1auo8o

enum Environment {
  dev,
  prod,
}

abstract class AppEnvironment {
  static late String? title;
  static late Environment _environment;

  static Environment get environment => _environment;

  static setupEnvironment(Environment env) {
    _environment = env;
    switch (env) {
      case Environment.dev:
        {
          title = 'Profi-Dev';
          break;
        }
      case Environment.prod:
        {
          title = 'Profi';
          break;
        }
    }
  }
}