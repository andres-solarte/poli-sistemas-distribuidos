package sd.entrega2;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PhoneLookupServer {
    private static final int DEFAULT_PORT = 5050;
    private static final String NOT_FOUND_MESSAGE = "Persona dueña de ese número telefónico no existe.";

    public static void main(String[] args) throws IOException {
        int port = args.length > 0 ? Integer.parseInt(args[0]) : DEFAULT_PORT;
        System.out.println("[server] Listening on port " + port);

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            while (true) {
                Socket clientSocket = serverSocket.accept();
                handleClient(clientSocket);
            }
        }
    }

    private static void handleClient(Socket socket) {
        System.out.println("[server] Client connected: " + socket.getRemoteSocketAddress());
        try (
            Socket client = socket;
            BufferedReader in = new BufferedReader(new InputStreamReader(client.getInputStream(), StandardCharsets.UTF_8));
            PrintWriter out = new PrintWriter(client.getOutputStream(), true, StandardCharsets.UTF_8)
        ) {
            String phone;
            while ((phone = in.readLine()) != null) {
                String cleanPhone = phone.trim();
                if (cleanPhone.isEmpty()) {
                    out.println("Ingrese un número de teléfono válido.");
                    continue;
                }
                if ("exit".equalsIgnoreCase(cleanPhone)) {
                    out.println("Sesión finalizada.");
                    break;
                }
                out.println(lookupByPhone(cleanPhone));
            }
        } catch (IOException e) {
            System.err.println("[server] I/O error: " + e.getMessage());
        }
        System.out.println("[server] Client disconnected");
    }

    private static String lookupByPhone(String phone) {
        String query = """
            SELECT p.dir_tel, p.dir_nombre, p.dir_direccion, c.ciud_nombre
            FROM personas p
            INNER JOIN ciudades c ON c.ciud_id = p.dir_ciud_id
            WHERE p.dir_tel = ?
            """;

        try (Connection conn = createConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, phone);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return NOT_FOUND_MESSAGE;
                }
                return String.format(
                    "Teléfono: %s | Nombre: %s | Dirección: %s | Ciudad: %s",
                    rs.getString("dir_tel"),
                    rs.getString("dir_nombre"),
                    rs.getString("dir_direccion"),
                    rs.getString("ciud_nombre")
                );
            }
        } catch (SQLException e) {
            return "Error consultando base de datos: " + e.getMessage();
        }
    }

    private static Connection createConnection() throws SQLException {
        String host = System.getenv().getOrDefault("DB_HOST", "127.0.0.1");
        String port = System.getenv().getOrDefault("DB_PORT", "3306");
        String database = System.getenv().getOrDefault("DB_NAME", "sd_entrega2");
        String user = System.getenv().getOrDefault("DB_USER", "sd_user");
        String password = System.getenv().getOrDefault("DB_PASSWORD", "sd_password");

        String url = "jdbc:mariadb://" + host + ":" + port + "/" + database;
        return DriverManager.getConnection(url, user, password);
    }
}
