

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class SimpleHttpServlet
 */
@WebServlet("/RequestHeaders")
public class SimpleHttpServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		// response.getWriter().append("Served at: ").append(request.getServerName());
		handleRequest(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//response.getWriter().append("Served at: ").append(request.getServerName());
		handleRequest(request, response);
	}
	
	// https://examples.javacodegeeks.com/enterprise-java/servlet/get-all-request-headers-in-servlet/
    public void handleRequest(HttpServletRequest req, HttpServletResponse res) throws IOException {
    	 
        PrintWriter out = res.getWriter();
        res.setContentType("text/plain");
 
        Enumeration<String> headerNames = req.getHeaderNames();
 
        out.write("getServerName()" + "\n");
        out.write("\t" + req.getServerName() + "\n\n");
        
        while (headerNames.hasMoreElements()) {
 
            String headerName = headerNames.nextElement();
            out.write(headerName);
            out.write("\n");
 
            Enumeration<String> headers = req.getHeaders(headerName);
            while (headers.hasMoreElements()) {
                String headerValue = headers.nextElement();
                out.write("\t" + headerValue);
                out.write("\n\n");
            }
 
        }
 
        out.close();
 
    }
}
