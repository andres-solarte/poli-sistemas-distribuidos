package sd.entrega2;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

public class PhoneLookupClient {
    private static final int DEFAULT_PORT = 5050;
    private static final String DEFAULT_HOST = "192.168.56.10";

    public static void main(String[] args) {
        String host = args.length > 0 ? args[0] : DEFAULT_HOST;
        int port = args.length > 1 ? Integer.parseInt(args[1]) : DEFAULT_PORT;

        System.out.printf("[client] Connected to %s:%d%n", host, port);
        System.out.println("[client] Escriba un numero telefonico o 'exit' para terminar.");

        try (
            Socket socket = new Socket(host, port);
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true, StandardCharsets.UTF_8);
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
            Scanner scanner = new Scanner(System.in, StandardCharsets.UTF_8)
        ) {
            int queryCount = 0;
            while (true) {
                System.out.print("Telefono: ");
                if (!scanner.hasNextLine()) {
                    out.println("exit");
                    break;
                }

                String phone = scanner.nextLine().trim();
                if (phone.isEmpty()) {
                    continue;
                }

                out.println(phone);
                String response = in.readLine();
                if (response == null) {
                    System.out.println("[client] El servidor cerró la conexión.");
                    break;
                }
                System.out.println(response);

                if ("exit".equalsIgnoreCase(phone)) {
                    break;
                }

                queryCount++;
                if (queryCount >= 2) {
                    System.out.print("Desea consultar otro numero? (s/n): ");
                    if (scanner.hasNextLine()) {
                        String answer = scanner.nextLine().trim();
                        if (!"s".equalsIgnoreCase(answer)) {
                            out.println("exit");
                            String goodbye = in.readLine();
                            if (goodbye != null) {
                                System.out.println(goodbye);
                            }
                            break;
                        }
                    } else {
                        out.println("exit");
                        break;
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("[client] Error de comunicación: " + e.getMessage());
        }
    }
}
