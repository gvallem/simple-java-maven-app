package com.mycompany.app;

import com.sun.net.httpserver.HttpServer;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class App {
  public static void main(String[] args) throws Exception {
    int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
    HttpServer server = HttpServer.create(new InetSocketAddress("0.0.0.0", port), 0);
    server.createContext("/", exchange -> {
      byte[] resp = "Hola mundo GCP".getBytes(StandardCharsets.UTF_8);
      exchange.sendResponseHeaders(200, resp.length);
      try (OutputStream os = exchange.getResponseBody()) { os.write(resp); }
    });
    server.setExecutor(null);
    System.out.println("Escuchando en puerto " + port);
    server.start();
  }
}


