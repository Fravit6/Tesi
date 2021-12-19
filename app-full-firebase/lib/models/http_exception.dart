/*
 * Classe per le eccezioni delle richieste http
 *
 * La utilizzo per stampare nella console gli errori personalizzati
 *
 * Implementa la classe Exception, quindi devo fare l'override di tutti i metodi
 */
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
    //return super.toString();
  }
}