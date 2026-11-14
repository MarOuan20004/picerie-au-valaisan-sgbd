package jdbc;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public class OracleDB {

    private static final String DEFAULT_URL = "jdbc:oracle:thin:@oracle1.ensimag.fr:1521:oracle1";
    private static final String DEFAULT_USER = "elhadarm";
    private static final String DEFAULT_PASS = "elhadarm";

    private static String url = DEFAULT_URL;
    private static String user = DEFAULT_USER;
    private static String pass = DEFAULT_PASS;

    static {
        loadConfiguration();
    }

    private static void loadConfiguration() {
        Properties props = new Properties();

        String[] configPaths = {"db.properties", "config.properties", "src/main/resources/db.properties"};
        for (String path : configPaths) {
            File f = new File(path);
            if (f.exists()) {
                try (InputStream in = new FileInputStream(f)) {
                    props.load(in);
                    break;
                } catch (Exception ignored) {}
            }
        }
        if (props.isEmpty()) {
            try (InputStream in = OracleDB.class.getResourceAsStream("/db.properties")) {
                if (in != null) props.load(in);
            } catch (Exception ignored) {}
        }

        if (System.getProperty("oracle.url") != null) {
            url = System.getProperty("oracle.url");
        } else if (System.getenv("ORACLE_URL") != null) {
            url = System.getenv("ORACLE_URL");
        } else if (System.getenv("DB_URL") != null) {
            url = System.getenv("DB_URL");
        } else if (props.getProperty("db.url") != null) {
            url = props.getProperty("db.url");
        }

        if (System.getProperty("oracle.user") != null) {
            user = System.getProperty("oracle.user");
        } else if (System.getenv("ORACLE_USER") != null) {
            user = System.getenv("ORACLE_USER");
        } else if (System.getenv("DB_USER") != null) {
            user = System.getenv("DB_USER");
        } else if (props.getProperty("db.user") != null) {
            user = props.getProperty("db.user");
        }

        if (System.getProperty("oracle.password") != null) {
            pass = System.getProperty("oracle.password");
        } else if (System.getenv("ORACLE_PASSWORD") != null) {
            pass = System.getenv("ORACLE_PASSWORD");
        } else if (System.getenv("ORACLE_PASS") != null) {
            pass = System.getenv("ORACLE_PASS");
        } else if (System.getenv("DB_PASSWORD") != null) {
            pass = System.getenv("DB_PASSWORD");
        } else if (props.getProperty("db.password") != null) {
            pass = props.getProperty("db.password");
        }
    }

    private Connection conn;
    public Connection getConnection() {
        return this.conn;
    }

    public OracleDB() {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            this.conn = DriverManager.getConnection(url, user, pass);
            System.out.println("Connexion Oracle reussie");
        } catch (Exception e) {
            System.out.println("Echec connexion Oracle");
            e.printStackTrace();
        }
    }

    /** ========== AFFICHAGE DE TABLEAU ========== */
    public void runQuery(String sql) {
        try {
            if (conn == null) {
                System.out.println("Impossible d'executer la requete : pas de connexion.");
                return;
            }

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            ResultSetMetaData meta = rs.getMetaData();
            int colCount = meta.getColumnCount();

            List<String[]> rows = new ArrayList<>();
            String[] header = new String[colCount];
            int[] widths = new int[colCount];

            for (int i = 1; i <= colCount; i++) {
                header[i - 1] = meta.getColumnName(i);
                widths[i - 1] = header[i - 1].length();
            }
            rows.add(header);

            while (rs.next()) {
                String[] line = new String[colCount];
                for (int i = 1; i <= colCount; i++) {
                    String val = String.valueOf(rs.getObject(i));
                    line[i - 1] = val;
                    widths[i - 1] = Math.max(widths[i - 1], val.length());
                }
                rows.add(line);
            }

            String border = "+";
            for (int w : widths) {
                border += "-".repeat(w + 2) + "+";
            }

            System.out.println(border);
            printRow(header, widths);
            System.out.println(border);

            for (int i = 1; i < rows.size(); i++) {
                printRow(rows.get(i), widths);
            }
            System.out.println(border);

            rs.close();
            stmt.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Affichage d'une ligne */
    private void printRow(String[] values, int[] widths) {
        StringBuilder sb = new StringBuilder("|");
        for (int i = 0; i < values.length; i++) {
            sb.append(" ")
              .append(String.format("%-" + widths[i] + "s", values[i]))
              .append(" |");
        }
        System.out.println(sb.toString());
    }

    /** ========== SIMPLE QUERY ========== */
    public class SimpleQuery {
        private String query;

        public SimpleQuery(String query) {
            this.query = query;
        }

        public ResultSet executeSelect() throws SQLException {
            PreparedStatement ps = conn.prepareStatement(query);
            return ps.executeQuery();
        }

        public int executeUpdate() throws SQLException {
            PreparedStatement ps = conn.prepareStatement(query);
            return ps.executeUpdate();
        }
    }

    public void close() {
        try {
            if (conn != null) conn.close();
            System.out.println("Connexion fermee.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void closeQuietly() {
        try {
            if (conn != null) conn.close();
        } catch (Exception ignored) {}
    }
}
