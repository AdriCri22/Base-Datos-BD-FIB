import java.sql.*;
import java.util.Properties;

public class gestioProfes
   {
   public static void main (String args[])
     {
	try
	   {
	   // carregar el driver al controlador
	   Class.forName ("org.postgresql.Driver");
           System.out.println ();
	   System.out.println ("Driver de PostgreSQL carregat correctament.");
           System.out.println ();


	   // connectar a la base de dades
	   // cal modificar el username, password i el nom de la base de dades
	   // en el servidor postgresfib, SEMPRE el SSL ha de ser true
	   Properties props = new Properties();
	   props.setProperty("user","NOMBRE.APELLIDO"); // Nombre de usuario
	   props.setProperty("password","DBdd/mm/aa");	// Contraseña
	   props.setProperty("ssl","true");
	   props.setProperty("sslfactory", "org.postgresql.ssl.NonValidatingFactory"); 
	   Connection c = DriverManager.getConnection("jdbc:postgresql://postgresfib.fib.upc.es:6433/DBNOMBRE.APELLIDO", props);
	   c.setAutoCommit(false);
	   System.out.println ("Connexio realitzada correctament.");
	   System.out.println ();


	   // canvi de l'esquema per defecte a un altre esquema
		 Statement s = c.createStatement();
		 s.executeUpdate("set search_path to public;");
		 s.close();					
	   System.out.println ("Canvi d'esquema realitzat correctament.");
           System.out.println ();

           
	   // IMPLEMENTAR CONSULTA
       String[] telfsProf = {"3111", "3222", "3333", "4444"};
       for (int i = 0; i < telfsProf.length; i++) {
    	   Statement s = c.createStatement();
    	   ResultSet r = s.executeQuery("SELECT dni, nomProf FROM professors WHERE telefon = '" + telfsProf[i] + "';");
    	   boolean exist = false;
    	   while (r.next()) {
    		   exist = true;
    		   String nomProf = r.getString("nomProf");
    		   String dniProf = r.getString("dni");
    		   System.out.println("Professor " + nomProf + " amb dni " + dniProf);
    	   }
    	   if (!exist) System.out.println("NO TROBAT");
    	   s.close();
       }
      
		   
	   // IMPLEMENTAR CANVI BD       
	   Statement rs = c.createStatement();
	   int mod = rs.executeUpdate("UPDATE despatxos d "
	       	+ "SET superficie = superficie + 3 "
	       	+ "WHERE d.modul = 'omega' AND "
	       	+ "not exists (SELECT * FROM assignacions a WHERE a.modul = 'omega' AND a.numero = d.numero AND a.instantFi is NULL);");
	   if (mod == 0) System.out.println("No se ha hecho ninguna modificación");
       
	   // Commit i desconnexio de la base de dades
	   c.commit();
	   c.close();
	   System.out.println ("Commit i desconnexio realitzats correctament.");
	   }
	
	catch (ClassNotFoundException ce)
	   {
	   System.out.println ("Error al carregar el driver");
	   }	
	catch (SQLException se)
	   {
			if (se.getSQLState().equals("23514")) System.out.println("Error: Superficie mayor a 25");
	 	   else {
		           System.out.println ("Excepcio: ");System.out.println ();
			   System.out.println ("El getSQLState es: " + se.getSQLState());
		           System.out.println ();
			   System.out.println ("El getMessage es: " + se.getMessage());	  
	 	   }
	   }
  }
}
