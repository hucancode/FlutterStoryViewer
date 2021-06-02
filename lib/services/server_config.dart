class ServerConfig
{
  static const USE_LOCALHOST = false;
  static const HOST_LOCAL = 'http://localhost';
  static const HOST_REMOTE = 'https://pop-ex.atpop.info';
  static const PORT = '3100';
  static const ENDPOINT = '${USE_LOCALHOST?HOST_LOCAL:HOST_REMOTE}:$PORT';
  static const TIMEOUT_IN_SECOND = 10;
}