<%@ Page Language="VB" %>
<%@ Import Namespace="System.Web.UI" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
   
    Protected Sub btnOK_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        Response.Redirect("~/home.aspx")
       
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BabySlang - Home</title>
    <link rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
</head>

<body>
    <form id="form1" runat="server">
       
    <!-- Begin Wrapper -->
    <div id="wrapper">
  
    <!-- Begin Header -->
    <div id="header"></div>
    <!-- End Header -->

  
    <!-- Begin Sub Header 3 -->
    <div id="subheader3"><h2>Server Connection Timeout</h2></div>
    <!-- End Sub Header 3 -->

    <!-- Begin Sub Header -->
    <div id="subheader" align="justify" style="font-family: Arial, Helvetica, sans-serif">
        <h2>Sorry, we are currently unable to load the requested page into your browser. </h2><br />
        <h2>This could be due to low bandwidth network connection from the host.</h2><br />
        <h2>Please Click &nbsp;<asp:Button ID="btnOK" runat="server" Text=" OK " Font-Size="X-Large" OnClick="btnOK_Click"/>&nbsp;
            to be go to the home page.</h2><br />
    </div>
    <!-- End Sub Header -->

    <!-- Begin Footer -->
    <div id="footer"><h5 align="right">Copyright BabySlang 2010</h5></div>
    <!-- End Footer -->
    </div>
    <!-- End Wrapper -->
    </form>
</body>
</html>
