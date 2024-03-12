<%@ Page Language="vb" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.String" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Net" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>
<script runat="server" language="vbscript">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        txtUserID.Focus() 'Set focus on User ID textbox
    End Sub
    
    Protected Sub btnLogin_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim objDBUser As New DBUser
        
        'Check if User ID and password matches
        If objDBUser.CheckUserLogin(Me.txtUserID.Text, Me.txtPassword.Text) = False Then
            'Check if user need to change his/her password
            If RenewPwd(txtPassword.Text) Then
                Session("UserEmail") = Me.txtUserID.Text.Trim
                Response.Redirect("~/changepwd.aspx")
            Else
                Session("UserEmail") = Me.txtUserID.Text.Trim
                Response.Redirect("~/maintainuservideo.aspx")
            End If
        Else
            lblMessage.Text = "Wrong Credentials. Please try again."
            txtPassword.Text = ""
            txtPassword.Focus()
            lblMessage.Visible = True
        End If
        
        'Validate if Email input has invalid characters
        If ValidEmail(txtUserID.Text) = False Then
            lblMessage.Text = "The Email Contains Invalid Characters."
            lblMessage.Visible = True
            txtUserID.Focus()
        End If
    End Sub
    
    'Procedure to redirect user to register if he/she does not have an account
    Protected Sub btnCreate_Click(ByVal sender As Object, ByVal e As EventArgs)
        Response.Redirect("~/Register.aspx")
    End Sub
    
    'Procedure to show the options for the user to reset his/her password
    Protected Sub lbtnForgotPwd_Click(ByVal sender As Object, ByVal e As EventArgs)
        lblMessage.Text = "Please enter your Email and click Send to receive your new password via Email."
        lblMessage.Visible = True
        table2.Visible = True
        table1.Visible = False
    End Sub
    
    'Procedure to reset user's password to the default password and send the password to him/her via Email
    Protected Sub btnSend_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim objDBUser As New DBUser
        Dim webAdmin As SmtpClient = New SmtpClient
        Dim email As New MailMessage
        
        If ValidEmail(txtEmail.Text) = False Then
            lblMessage.Text = "The Email Contains Invalid Characters."
            txtEmail.Focus()
            Exit Sub
        End If
        'Check if the Email entered is a valid Email account
        If objDBUser.CheckEmail(txtEmail.Text) = False Then
            
            email.To.Clear()
            email.To.Add(New MailAddress(txtEmail.Text))
            email.From = New MailAddress("babyslang2010@gmail.com")
            email.Subject = "Password Reset"
        
            'This object stores the authentication values
            Dim basicAuthenticationInfo As New NetworkCredential("babyslang2010@gmail.com", "81631123")
            'Put your own, or your ISPs, mail server name onthis next line
            webAdmin.Port = 587
            webAdmin.Host = "smtp.gmail.com"
            webAdmin.UseDefaultCredentials = False
            webAdmin.Credentials = basicAuthenticationInfo
            webAdmin.EnableSsl = True

            Try
                ResetPwd()
                email.Body = " Your new user account password: pwd1234. Please change your password at the next login."
                webAdmin.Send(email)
                lblMessage.Text = "The default password will be sent to your Email in 15 minutes time. While waiting, you are most welcome to explore the website features."
            Catch ex As Exception
                Response.Write("Error: " & ex.ToString())
            End Try
        Else
            lblMessage.Text = "The Email provided is not registered with BabySlang."
        End If
    End Sub
    
    'Procedure to allow user to cancel password reset and display the login controls
    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As EventArgs)
        table1.Visible = True
        table2.Visible = False
        lblMessage.Visible = False
    End Sub
    
    'Procedure to check if the password entered is the default password
    Protected Function RenewPwd(ByVal strPwd As String) As Boolean
        If strPwd = "pwd1234" Then
            Return True
        Else
            Return False
        End If
    End Function
    
    'Procedure to reset user's password to the default password
    Protected Sub ResetPwd()
        Dim objCmd As New SqlCommand
        Dim objCn As New SqlConnection
        Dim strSQL As String
        Dim intNumOfRecordsAffected As Integer
        
        Const CONNSTRING As String = "Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_member;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"
        
        strSQL = "UPDATE tbUsers SET Password='pwd1234' WHERE Email ='" & txtEmail.Text.Trim & "';"
       
        objCn.ConnectionString = CONNSTRING
        objCn.Open()
        objCmd.CommandText = strSQL
        objCmd.Connection = objCn
        intNumOfRecordsAffected = objCmd.ExecuteNonQuery()
        objCn.Close()
    End Sub
    
    'Procedure to Check for valid input
    Protected Function ValidEmail(ByVal strInput As String) As Boolean
        Dim num As Integer
        Dim tmpString As String
   
        tmpString = strInput 'Assign value to temporary variable
        
        'Increase the value of variable num if the following characters are found
        num += InStr(tmpString, "`")
        num += InStr(tmpString, "~")
        num += InStr(tmpString, "#")
        num += InStr(tmpString, "$")
        num += InStr(tmpString, "^")
        num += InStr(tmpString, "&")
        num += InStr(tmpString, "*")
        num += InStr(tmpString, "(")
        num += InStr(tmpString, ")")
        num += InStr(tmpString, "=")
        num += InStr(tmpString, "+")
        num += InStr(tmpString, "[")
        num += InStr(tmpString, "{")
        num += InStr(tmpString, "]")
        num += InStr(tmpString, "}")
        num += InStr(tmpString, "\")
        num += InStr(tmpString, "|")
        num += InStr(tmpString, ";")
        num += InStr(tmpString, ":")
        num += InStr(tmpString, "'")
        num += InStr(tmpString, """")
        num += InStr(tmpString, "<")
        num += InStr(tmpString, ">")
        num += InStr(tmpString, "/")
        num += InStr(tmpString, "!")
        num += InStr(tmpString, ",")
        num += InStr(tmpString, "?")
        num += InStr(tmpString, "%")

        If num = 0 Then
            Return True 'Return True if none of the characters are found
        Else
            Return False 'Return False if the characters are found
        End If
    End Function
    
    ''''''''''''''''''''''''''''''''''''''''Class Objects''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    Public Class DBUser
        Inherits System.Web.UI.Page
        Dim objCmd As New SqlCommand
        Dim objCn As New SqlConnection
        Dim strSQL As String
        Const CONNSTRING As String = "Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_member;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"

        Sub New()
            objCn = New SqlConnection
            objCmd = New SqlCommand
            objCmd.Connection = objCn
            objCn.ConnectionString = CONNSTRING
        End Sub

        Dim objAdapter As New SqlDataAdapter
        Dim objDs As New DataSet
        Dim objDataRow As DataRow
        Public Function RetrieveOneUserID(ByVal pstrEmail As String) As User1
            Dim objArrayList As New ArrayList
            strSQL = "SELECT * FROM tbUsers WHERE Email = '" & pstrEmail & "'"
            objCn.Open()

            objCmd.CommandText = strSQL
            objAdapter.SelectCommand = objCmd
            objAdapter.Fill(objDs, "tbUsers")
            objDataRow = objDs.Tables("tbUsers").Rows(0)


            Dim objUser As New User1

            objUser.UserID = objDataRow.Item("UserID")
            Session("UserID") = objUser.UserID
            objUser.UserName = objDataRow.Item("UserName")
            Session("UserName") = objUser.UserName
            objUser.Password = objDataRow.Item("Password")
            Session("Email") = objUser.UserName
            objUser.Email = objDataRow.Item("Email")

            objCn.Close()
            Return objUser
        End Function
        Public Function CheckUserLogin(ByVal pstrEmail As String, ByVal pstrPassword As String) As Boolean

            Dim intNumOfRowRetrieved As Integer
            intNumOfRowRetrieved = 0
            strSQL = "SELECT * from tbUsers WHERE Email = '{0}'AND Password ='{1}' "

            strSQL = String.Format(strSQL, pstrEmail, pstrPassword)

            objCmd.CommandText = strSQL
            objCn.Open()
            intNumOfRowRetrieved = objCmd.ExecuteScalar
            objCn.Close()

            If intNumOfRowRetrieved >= 1 Then
                Return False
            Else
                Return True
            End If
        End Function
        Public Function addUser(ByVal objUser As User1) As Integer
            Dim intNumOfRecordsAffected As Integer
            Dim strSQL As String

            strSQL = "INSERT INTO tbUsers(UserName, Password, Email) VALUES('" & _
           objUser.UserName & "', '" & objUser.Password & "', '" & objUser.Email & "')"
            objCmd.CommandText = strSQL

            objCn.Open()
            intNumOfRecordsAffected = objCmd.ExecuteNonQuery()
            objCn.Close()
            Return intNumOfRecordsAffected
        End Function
        
        Public Function CheckEmail(ByVal pstrEmail As String) As Boolean

            ' Dim blnDuplicate As Boolean
            Dim intNumOfRowRetrieved As Integer
            intNumOfRowRetrieved = 0
            strSQL = "SELECT * from tbUsers WHERE Email = '{0}'"

            strSQL = String.Format(strSQL, pstrEmail)

            objCmd.CommandText = strSQL
            objCn.Open()
            intNumOfRowRetrieved = objCmd.ExecuteScalar
            objCn.Close()

            If intNumOfRowRetrieved >= 1 Then
                Return False
            Else
                Return True
            End If

        End Function
    End Class
    
    Public Class User1
        Public strUserID As String
        Public strUserName As String
        Public strPassword As String
        Public strEmail As String

        Property UserID() As String
            Get
                Return strUserID
            End Get
            Set(ByVal Value As String)
                strUserID = Value
            End Set
        End Property
        Property UserName() As String
            Get
                Return strUserName
            End Get
            Set(ByVal Value As String)
                strUserName = Value
            End Set
        End Property
        Property Password() As String
            Get
                Return strPassword
            End Get
            Set(ByVal Value As String)
                strPassword = Value
            End Set
        End Property
        Property Email() As String
            Get
                Return strEmail
            End Get
            Set(ByVal Value As String)
                strEmail = Value
            End Set
        End Property
    End Class
    ''''''''''''''''''''''''''''''''''''''''End of Script''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BabySlang - Signing Exact English (SEE) Educational Resource Website</title>
        <link id="Link1" runat="server" rel="stylesheet" type="text/css" href="~/css/styles_home.css" />

</head>

<body>
    <form id="form1" runat="server">
    
    <!-- Begin Wrapper -->    
    <div id="wrapper">

    <!-- Begin Sub Header 2 -->
    <div id="subheader2"></div>
    <!-- End Sub Header 2 -->

    <!-- Begin Sub Header -->
    <div id="subheader"><h2>Log In</h2></div>
    <!-- End Sub Header -->

    <!-- Begin Navigation -->
    <div id="navigation">
        <ul id="Menu">
            <li><a href="http://www.babyslang.net/aboutus.aspx"><span>About Us</span></a></li>
            <li><a href="http://www.babyslang.net/quiz.aspx"><span>Fun Quiz</span></a></li>
            <li><a href="http://www.babyslang.net/learnithome.aspx"><span>Learn SEE</span></a></li>
            <li><a href="http://www.babyslang.net/translateMain.aspx"><span>Translate to SEE</span></a></li>
            <li><a href="http://www.babyslang.net/home.aspx"><span>Home</span></a></li>
        </ul>
    </div>
    <!-- End Navigation -->
       
    <!-- Begin Sub Header 3 -->
    <div id="subheader3">
    <h2>Please Enter Your Email and Password and Click Log In</h2>    
    </div>
    <!-- End Sub Header -->
   
    <!-- Begin Left Column Half -->
    <div id="leftcolumn_half">        
    
        <asp:Label cssclass="warning2" ID="lblMessage" runat="server" Text="Label" Visible="false"  Font-Size="Large"></asp:Label>
        <br /><br />
        <asp:Table ID="table1" runat="server" width= "100%" Height="125px">
            
            <asp:TableRow ID="tablerow1" runat="server">
                <asp:TableCell id="tablecell1" runat="server">
                    <h2>Email : </h2>
                </asp:TableCell>
                <asp:TableCell id="tablecell2" runat="server">
                    &nbsp;<asp:TextBox ID="txtUserID" runat="server" Height="25px" Width="90%" Font-Size="Large" />
                </asp:TableCell></asp:TableRow><asp:TableRow ID="tablerow2" runat="server">
                <asp:TableCell id="tablecell3" runat="server">
                    <h2>Password : </h2>
                </asp:TableCell><asp:TableCell id="tablecell4" runat="server">
                    &nbsp;<asp:TextBox ID="txtPassword" runat="server" Height="25px" Width="90%" Font-Size="Large" TextMode="Password" />
                </asp:TableCell></asp:TableRow><asp:TableRow ID="tablerow4" runat="server">
                <asp:TableCell id="tablecell7" runat="server">
                    &nbsp;
                </asp:TableCell><asp:TableCell id="tablecell6" runat="server">
                    <asp:Button ID="btnLogin" runat="server" Text=" Log In " Font-Size="Large" OnClick="btnLogin_Click" />&nbsp;
                    <asp:LinkButton ID="lbtnForgotPwd" runat="server" Font-Size="Medium" OnClick="lbtnForgotPwd_Click">Forgot Your Password?</asp:LinkButton>
                </asp:TableCell></asp:TableRow></asp:Table><h1>&nbsp;</h1><asp:Table ID="table2" runat="server" height="25%" width= "100%" Visible="false">
            <asp:TableRow ID="tablerow5" runat="server">
                <asp:TableCell id="tablecell8" runat="server">
                    <h2>Email : </h2>
                </asp:TableCell><asp:TableCell id="tablecell9" runat="server">
                    &nbsp;<asp:TextBox ID="txtEmail" runat="server" Height="25px" Width="90%" Font-Size="Large" />
                </asp:TableCell></asp:TableRow><asp:TableRow ID="tablerow6" runat="server">
                <asp:TableCell id="tablecell10" runat="server">
                    &nbsp;
                </asp:TableCell><asp:TableCell id="tablecell11" runat="server">
                    <asp:Button ID="btnSend" runat="server" Text=" Send " Font-Size="Large" OnClick="btnSend_Click" />&nbsp;
                    <asp:Button ID="btnCancel" runat="server" Text=" Cancel " Font-Size="Large" OnClick="btnCancel_Click" />
                </asp:TableCell></asp:TableRow></asp:Table><h1>&nbsp;</h1><asp:Table ID="table3" runat="server" HorizontalAlign="Center">
        
            <asp:TableRow ID="tablerow7" runat="server">
                <asp:TableCell id="tablecell12" runat="server">
                    <h2>New to BabySlang?</h2>
                </asp:TableCell><asp:TableCell id="tablecell13" runat="server">&nbsp;
                    <asp:Button ID="btnCreate" runat="server" Text=" Create Account " Font-Size="Large" OnClick="btnCreate_Click" />
                </asp:TableCell></asp:TableRow></asp:Table></div><!-- End Left Column Half--><!-- Begin Right Column Half--><div id="rightcolumn_half">
        <asp:Table ID="table4" runat="server" HorizontalAlign="Center" height="290px" width= "425px">
            <asp:TableRow ID="tablerow3" runat="server">
                <asp:TableCell id="tablecell5" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                    <asp:Image ID="image1" runat="server" height="290px" width= "425px" Visible="true" ImageUrl="~/pictures/loginregister.jpg" />
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>
   </div>
   <!-- End Right Column Half -->
   
   <!-- Begin Footer -->
   <div id="footer"><h6 align="right">Copyright BabySlang 2010</h6></div>
   <!-- End Footer -->

   </div>
   <!-- End Wrapper -->
    </form>
</body>
</html>
