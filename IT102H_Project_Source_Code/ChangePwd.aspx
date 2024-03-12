<%@ Page Language="vb"%>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.String" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>
<script runat="server" language="vbscript">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        
        'Check if page is referred after user is authenticated at log in
        'Redirect user to log in if not from log in page
        If Request.UrlReferrer Is Nothing Then
            Response.Redirect("~/Login.aspx")
            Exit Sub
        End If
        
        Me.txtCurrentPwd.Focus() 'Set focus to the current password textbox
        txtEmail.Text = Session("UserEmail")
        txtEmail.Enabled = False 'Disable the Email textbox to disallow user to change their User ID
        
    End Sub
    
    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim objDBUser As New DBUser
        Dim objUser As User1
        
        'Retrieve details of the current user
        objUser = objDBUser.RetrieveOneUserID(txtEmail.Text)
        
        If objUser.Password = "pwd1234" Then 'Check if user's password is still the default password
            Response.Redirect("~/Login.aspx") 'Redirect user to log in page if password is still the default password
        Else
            Response.Redirect("~/MaintainUserVideo.aspx") 'Redirect user to maintain user video page
        End If
        
    End Sub
    
    Protected Sub btnChange_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim objUser As New User1
        Dim objDBUser As New DBUser
        Dim upload As New FileClass
        
        'Check if the User ID and current password is correct
        If objDBUser.CheckUserLogin(txtEmail.Text, txtCurrentPwd.Text) = True Then
            lblMessage.Text = "Incorrect Current Password."
            Exit Sub
        End If
        
        'Check if password text box is empty
        If txtPassword.Text = "" Then
            lblMessage.Text = "Please Enter a Password."
            txtPassword.Focus()
            lblMessage.Visible = True
            Exit Sub
        End If
        
        'Check if password text box has more than 50 characters
        If txtPassword.Text.Length > 50 Then
            lblMessage.Text = "Please Enter a Shorter Password."
            txtPassword.Focus()
            lblMessage.Visible = True
            Exit Sub
        End If
        
        'Check if new password and re-type password matches
        If Me.txtPassword.Text <> Me.txtPassword0.Text Then
            Me.lblMessage.Text = "Both Passwords Do Not Match. Please Re-Enter Again."
            txtPassword.Text = ""
            txtPassword0.Text = ""
            txtPassword.Focus()
            lblMessage.Visible = True
            Exit Sub
        End If
        
        objDBUser.ChangePwd(txtEmail.Text, txtPassword.Text) 'Change user password in the database
        Session("UserEmail") = ""
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/Login.aspx") 'Redirect user back to maintain videos page after change is successful
        
    End Sub
    
    ''''''''''''''''''''''''''''''''''''''''Class Objects''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

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
            strSQL = "SELECT * from tbUsers WHERE Email = '{0}' AND Password ='{1}' "

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
        
        Public Sub ChangePwd(ByVal strUserID As String, ByVal strPwd As String)
            Dim intNumOfRecordsAffected As Integer
            Dim strSQL As String

            strSQL = "UPDATE tbUsers SET Password='"& strPwd & "' WHERE Email='" & strUserID & "';"
            objCmd.CommandText = strSQL

            objCn.Open()
            intNumOfRecordsAffected = objCmd.ExecuteNonQuery()
            objCn.Close()
        End Sub
        
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
    
    Public Class FileClass

        Private strDBURL As String
        Public strExactURL As String

        Public Sub uploadFile(ByVal strUnitNo As String, ByVal strType As String, _
        ByVal strTypeName As String, ByVal uFile As System.Web.UI.HtmlControls.HtmlInputFile)
            
            Dim strSavePathName, strInputPath, strFileNameOnly As String
            Dim intFileNameLength As Integer

            'Exact file location to be saved
            strSavePathName = "~/MemberVideos/" & strUnitNo.Trim & "/" & strType.Trim & "/" & strTypeName.Trim & "/"

            'Create folder
            System.IO.Directory.CreateDirectory(strSavePathName)

            'Get the file name and upload the file into the exact location in the disk
            strInputPath = uFile.PostedFile.FileName

            'Extract the length of the file name
            intFileNameLength = InStr(1, StrReverse(strInputPath), "/")

            'Extract the file name with extension
            strFileNameOnly = Mid(strInputPath, (Len(strInputPath) - intFileNameLength) + 2)

            'Concat the location and file name
            strExactURL = strSavePathName & strFileNameOnly

            'Session("strExactURL") = strExactURL
            'Session("strFileNameOnly") = strFileNameOnly
            'Session("strInputPath") = strInputPath

            'Save file to the exact location
            uFile.PostedFile.SaveAs(strExactURL)

            'File location saved into database
            strDBURL = "/IBD/" & strUnitNo.Trim & "/" & strType.Trim & "/" & strTypeName.Trim & "/" & strFileNameOnly

        End Sub

        Public Sub deleteFile(ByVal myFile As String)
            Dim FileToDelete As String

            FileToDelete = myFile

            If System.IO.File.Exists(FileToDelete) = True Then

                System.IO.File.Delete(FileToDelete)

            End If
        End Sub

        Public Property DBUrl() As String
            Get
                Return strDBURL
            End Get
            Set(ByVal Value As String)
                strDBURL = Value.Trim
            End Set
        End Property

        Public Property ExactUrl() As String
            Get
                Return strExactURL
            End Get
            Set(ByVal Value As String)
                strExactURL = Value.Trim
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
    <div id="subheader"><h2>Change Password</h2></div>
    <!-- End Sub Header -->

    <!-- Begin Navigation -->
    <div id="navigation">
    </div>
    <!-- End Navigation -->
       
    <!-- Begin Sub Header 3 -->
    <div id="subheader3">
        <h2>Please Fill in all the Required Fields Below and Click Confirm</h2>
    </div>
    <!-- End Sub Header -->
   
    <!-- Begin Left Column Half -->
    <div id="leftcolumn_half">
        <asp:Label ID="Label1" runat="server" Text="Please note that members will be re-directed to Log In page upon successful password change." Font-Size="Large"></asp:Label><br /><br />
        <asp:Label ID="lblMessage" cssclass="warning2" Font-Size="Large" runat="server" />
        <br />
        <br />
        <asp:Table ID="table1" runat="server" HorizontalAlign="Center" height="200px" width= "425px">
 
            <asp:TableRow id="TableRow2" runat="server">  
                <asp:TableCell ID="TableCell3" runat="server">
                    <h3>Email :</h3>                 
                </asp:TableCell>
                <asp:TableCell ID="TableCell4" runat="server">
                     <asp:TextBox ID="txtEmail" runat="server" width="100%" Font-Size="Large"></asp:TextBox>
                </asp:TableCell>
            </asp:TableRow>

            <asp:TableRow ID="tablerow1" runat="server">
                <asp:TableCell id="tablecell1" runat="server" VerticalAlign="Middle">
                    <h3>Current Password :</h3>    
                </asp:TableCell>
                <asp:TableCell id="TableCell2" runat="server">
                    <asp:TextBox ID="txtCurrentPwd" runat="server" width="100%" Font-Size="Large" TextMode="Password"></asp:TextBox>
                </asp:TableCell>
            </asp:TableRow>

            <asp:TableRow id="TableRow4" runat="server">
                <asp:TableCell ID="TableCell6" runat="server"> 
                    <h3>New Password:</h3>                  
                </asp:TableCell>
                <asp:TableCell ID="TableCell7" runat="server">
                    <asp:TextBox ID="txtPassword" runat="server" width="100%" Font-Size="Large" TextMode="Password">password</asp:TextBox>
                </asp:TableCell>
            </asp:TableRow>

            <asp:TableRow id="TableRow5" runat="server">
                <asp:TableCell ID="TableCell8" runat="server">
                    <h3>Re-type Password:</h3>
                </asp:TableCell>
                <asp:TableCell ID="TableCell9" runat="server">
                    <asp:TextBox ID="txtPassword0" runat="server" width="100%" Font-Size="Large" TextMode="Password">password0</asp:TextBox>
                </asp:TableCell>
            </asp:TableRow>

            <asp:TableRow id="TableRow6" runat="server">
                <asp:TableCell ID="TableCell11" runat="server">
                    &nbsp;
                </asp:TableCell>
                <asp:TableCell ID="TableCell10" runat="server">
                    <asp:Button ID="btnChange" runat="server" Text=" Confirm " Font-Size="Large" OnClick="btnChange_Click" />&nbsp;
                    <asp:Button ID="btnCancel" runat="server" Text=" Cancel " Font-Size="Large" OnClick="btnCancel_Click"/>
                </asp:TableCell>
            </asp:TableRow>    
        </asp:Table>      
    </div>
    <!-- End Left Column Half-->      
  
    <!-- Begin Right Column Half-->
    <div id="rightcolumn_half">
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
