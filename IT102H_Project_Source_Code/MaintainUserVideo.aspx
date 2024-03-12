<%@ Page Language="vb" debug="true"%>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.String" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1); //Disable Brower's Back Button

</script>
<script runat="server" language="vbscript">
    Dim videoURL As String 'URL of the video to be played
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        'Check if page is referred after user is authenticated at log in
        'Redirect user to log in if not from log in page
        If Request.UrlReferrer Is Nothing Then
            Response.Redirect("~/Login.aspx")
            Exit Sub
        End If
               
        Dim objUserVideo As New UserVideo
        Dim objDBUserVideo As New DBUserVideo
        Dim objUser As New User1
        Dim objDBUser As New DBUser
        Dim strEmail As String

        strEmail = Session("UserEmail")
        objDBUser.RetrieveOneUserID(strEmail) 'Retrieve the record of the authenticated user

        Me.lblUserId.Text = Session("UserID") 'Assign User ID to temporary storage
        Me.lblUserName.Text = Session("UserName") 'Assign User Name to temporary storage
        
        'Check if user has exceeded the quota for uploading videos
        If objDBUserVideo.CheckNumOfVideo(Session("UserID")) >= 5 Then
            Me.btnAdd.Enabled = False
            Me.lblMessage.Text = "You have reached your upload quota (5 videos)."
            lblMessage.Visible = True
        Else
            Me.btnAdd.Enabled = True
           
            If Request.QueryString("uploaded") = 1 Then
                lblMessage.Text = "Video Uploaded Successfully."
                lblMessage.Visible = True
            ElseIf Request.QueryString("deleted") = 1 Then
                lblMessage.Text = "Video Deleted Successfully."
                lblMessage.Visible = True
            ElseIf Request.QueryString("updated") = 1 Then
                lblMessage.Text = "Video Details Updated Successfully."
                lblMessage.Visible = True
            Else
                Me.lblMessage.Text = ""
            End If
        End If
    End Sub
    
    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim objUserVideo As New UserVideo
        Dim objDBUserVideo As New DBUserVideo
        Dim intNumOfRecord As Integer
        Dim videoFileDirectory As String
        Dim videoFullPath As String
        
        'Check for empty input for video title
        If txtVideoTitle.Text = "" Then
            lblMessage.Text = "Please Enter a Video Title."
            lblMessage.Visible = True
            txtVideoTitle.Focus()
            Exit Sub
        End If
        
        'Check if video title exceed 80 characters
        If txtVideoTitle.Text.Length > 80 Then
            lblMessage.Text = "Please Enter a Shorter Video Title."
            lblMessage.Visible = True
            txtVideoTitle.Focus()
            Exit Sub
        End If
        
        'Check if video title contains special characters
        If ValidText(txtVideoTitle.Text) = False Then
            lblMessage.Text = "Please Enter ONLY Alphanumeric Characters for the Video Title."
            lblMessage.Visible = True
            txtVideoTitle.Focus()
            Exit Sub
        End If
        
        'Check for duplicate video title in the database records
        If objDBUserVideo.CheckVideoTitle(CInt(Me.lblUserId.Text), Me.txtVideoTitle.Text) = False Then
            Me.lblMessage.Text = "Duplicate Video Title Found"
            lblMessage.Visible = True
            Exit Sub
        End If
        
        If Not Video.HasFile Then
            lblMessage.Text = "No file has been selected." 'Inform user that no file has been selected
            lblMessage.Visible = True
            Exit Sub
        End If
        
        If Not ValidFile(Video.FileName) Then
            lblMessage.Text = "Only .asf, .wmv, .wm, .avi, .mpe, .mpeg, .mpg, .m1v  files are accepted."
            lblMessage.Visible = True
            Video.Focus()
            Exit Sub
        End If
        
        If Video.FileName.Length > 80 Then 'Check if the video filename exceeds 80 characters
            'Inform user that video filename is too long
            lblMessage.Text = "Your Video Filename is too long. Please Change to a Shorter Name."
            lblMessage.Visible = True
            Video.Focus()
            Exit Sub
        End If
        
        If Video.HasFile Then 'Check if a video file has been selected from the local computer
                            
            'Assign the video details to an object for temporary storage
            objUserVideo.UserID = Me.lblUserId.Text.Trim
            objUserVideo.VideoTitle = Me.txtVideoTitle.Text.Trim
            objUserVideo.VideoName = Video.FileName
                
            'Create the directory path of the video file to be saved in the web server
            videoFileDirectory = Server.MapPath("~/") & "membervideos\" & lblUserId.Text & "\" '
                
            'Create directory if it do not exist
            If System.IO.Directory.Exists(videoFileDirectory) = False Then
                System.IO.Directory.CreateDirectory(videoFileDirectory)
            End If
            
            videoFullPath = videoFileDirectory & Video.FileName 'Creates the full path of the video file to be saved in the web server
            Video.SaveAs(videoFullPath) 'Uploads the video file from local computer to web server
            intNumOfRecord = objDBUserVideo.addUserVideo(objUserVideo) 'Update the database on the additional video
            'refresh the page
            Me.Response.Redirect("~/MaintainUserVideo.aspx?uploaded=1")
        End If
    End Sub
 
    Protected Sub grdVideo_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles grdVideo.RowCommand
        Dim objDBUserVideo As New DBUserVideo
        Dim VideoID As Integer
        'if the link delete is click
        If e.CommandName = "Delete" Then
            VideoID = e.CommandArgument
            'delete the kiosk where the link is click
            objDBUserVideo.deleteUserVideo(VideoID)
            'refresh the page
            Me.Response.Redirect("MaintainUserVideo.aspx?deleted=1")

        ElseIf e.CommandName = "Update" Then
            VideoID = e.CommandArgument
            Me.Response.Redirect("UpdateUserVideo.aspx?id=" & VideoID)
        ElseIf e.CommandName = "View" Then
            VideoID = e.CommandArgument
            lblMessage.Visible = False
            CreateVideoURL(VideoID)
            table4.Visible = False
            table1.Visible = True
        End If
    End Sub
    
    Protected Sub btnChangePwd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/ChangePwd.aspx")
    End Sub
    
    'Procedure to clear all session variables and redirect user to home page after logged out
    Protected Sub btnLogOut_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Session("strExactURL") = ""
        Session("strFileNameOnly") = ""
        Session("strInputPath") = ""
        Session("UserID") = ""
        Session("UserName") = ""
        Session("Email") = ""
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/home.aspx")
    End Sub
    
    'Procedure to check for disallowed characters in the text box
    Protected Function ValidText(ByVal tmpstring As String) As Boolean
        Dim num As Integer
               
        'Increase the value of variable num if the following characters are found
        num += InStr(tmpString, "`")
        num += InStr(tmpString, "~")
        num += InStr(tmpString, "@")
        num += InStr(tmpString, "#")
        num += InStr(tmpString, "$")
        num += InStr(tmpString, "^")
        num += InStr(tmpString, "&")
        num += InStr(tmpString, "*")
        num += InStr(tmpString, "(")
        num += InStr(tmpString, ")")
        num += InStr(tmpString, "_")
        num += InStr(tmpString, "-")
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
        num += InStr(tmpstring, "%")
        
        If num = 0 Then
            Return True 'Return True if none of the characters are found
        Else
            Return False 'Return False if the characters are found
        End If
    End Function
    
    'Procedure to check for disallowed characters in the text box
    Protected Function ValidFile(ByVal tmpstring As String) As Boolean
        Dim correct As Boolean
        correct = False
        'change the value of variable correct if the following file extensions are found
        '.asf|.ASF|.wmv|.WMV|.wm|.WM|.avi|.AVI|.mpe|.MPE|.mpeg|.MPEG|.mpg|.MPG|.m1v|.M1V
        
        If tmpstring.EndsWith("asf") Then correct = True
        If tmpstring.EndsWith("wmv") Then correct = True
        If tmpstring.EndsWith("wm") Then correct = True
        If tmpstring.EndsWith("avi") Then correct = True
        If tmpstring.EndsWith("mpe") Then correct = True
        If tmpstring.EndsWith("mpeg") Then correct = True
        If tmpstring.EndsWith("mpg") Then correct = True
        If tmpstring.EndsWith("m1v") Then correct = True
        
        Return correct
        
    End Function
    
    Protected Sub CreateVideoURL(ByVal strKey As String) 'Create the URL for the video
        Dim sqlStatement As String
        Dim sqlConn As SqlConnection
        Dim sqlcmd As SqlCommand
        Dim drTbUserVideos As SqlDataReader
        
        sqlStatement = "SELECT USERID, VIDEONAME FROM tbUserVideos WHERE VIDEOID=" & strKey & ";"
        sqlConn = New SqlConnection("Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_member;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200")
        sqlConn.Open()
        sqlcmd = New SqlCommand(sqlStatement, sqlConn)
        
        'executing the command and assigning it to connection 
        drTbUserVideos = sqlcmd.ExecuteReader()
        
        drTbUserVideos.Read()
        
        videoURL = "http://www.babyslang.net/membervideos/" & drTbUserVideos(0) & "/" & drTbUserVideos(1)
        drTbUserVideos.Close()
        sqlConn.Close()
    End Sub
    ''''''''''''''''''''''''''''''''''''''''Class Objects''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    Public Class FileClass

        Private strDBURL As String
        Public strExactURL As String
        Dim rootFolder As String
        
        Public Sub uploadFile(ByVal strUnitNo As String, ByVal strType As String, ByVal uFile As System.Web.UI.WebControls.FileUpload) 'ByVal strTypeName As String, 
            Dim strSavePathName, strInputPath, strFileNameOnly As String
            Dim intFileNameLength As Integer
                        
            rootFolder = HttpContext.Current.Server.MapPath("~/")
            
            'Exact file location to be saved
            strSavePathName = rootFolder & strUnitNo.Trim & "\" & strType.Trim & "\" '& strTypeName.Trim & "\"
            'HttpContext.Current.Response.Write(strSavePathName)

            'Create folder
            System.IO.Directory.CreateDirectory(strSavePathName)

            'Get the file name and upload the file into the exact location in the disk
            strInputPath = uFile.PostedFile.FileName

            'Extract the length of the file name
            intFileNameLength = InStr(1, StrReverse(strInputPath), "\")

            'Extract the file name with extension
            strFileNameOnly = Mid(strInputPath, (Len(strInputPath) - intFileNameLength) + 2)

            'Concat the location and file name
            strExactURL = strSavePathName & strFileNameOnly

            HttpContext.Current.Session("strExactURL") = strExactURL
            HttpContext.Current.Session("strFileNameOnly") = strFileNameOnly
            HttpContext.Current.Session("strInputPath") = strInputPath

            'Save file to the exact location
            uFile.PostedFile.SaveAs(strExactURL)
          
            'File location saved into database
            strDBURL = strFileNameOnly

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
    
    Public Class UserVideo
        Protected intVideoID As String
        Protected intUserID As String
        Protected strVideoTitle As String
        Protected strVideoName As String

        Property VideoID() As String
            Get
                Return intVideoID
            End Get
            Set(ByVal Value As String)
                intVideoID = Value
            End Set
        End Property
        Property UserID() As String
            Get
                Return intUserID
            End Get
            Set(ByVal Value As String)
                intUserID = Value
            End Set
        End Property
        Property VideoTitle() As String
            Get
                Return strVideoTitle
            End Get
            Set(ByVal Value As String)
                strVideoTitle = Value
            End Set
        End Property
        Property VideoName() As String
            Get
                Return strVideoName
            End Get
            Set(ByVal Value As String)
                strVideoName = Value
            End Set
        End Property
    End Class

    Public Class DBUserVideo
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
        Public Function addUserVideo(ByVal objUserVideo As UserVideo) As Integer
            Dim intNumOfRecordsAffected As Integer
            Dim strSQL As String

            strSQL = "INSERT INTO tbUserVideos(UserID, VideoTitle, VideoName) VALUES('" & objUserVideo.UserID & "','" & objUserVideo.VideoTitle & "', '" & objUserVideo.VideoName & "')"

            objCmd.CommandText = strSQL
            objCn.Open()
            intNumOfRecordsAffected = objCmd.ExecuteNonQuery()
            objCn.Close()
            Return intNumOfRecordsAffected
        End Function
        
        Public Function CheckNumOfVideo(ByVal pintUserID As Integer) As Integer
            Dim intNumOfRowRetrieved As Integer
            intNumOfRowRetrieved = 0
            strSQL = "SELECT count(*) from tbUserVideos WHERE UserID = '{0}'"

            strSQL = String.Format(strSQL, pintUserID)

            objCmd.CommandText = strSQL
            objCn.Open()
            intNumOfRowRetrieved = objCmd.ExecuteScalar
            objCn.Close()
            Return intNumOfRowRetrieved
        End Function
        
        Public Function CheckVideoTitle(ByVal pintUserID As Integer, ByVal pstrVideoTitle As String) As Boolean

            Dim intNumOfRowRetrieved As Integer
            intNumOfRowRetrieved = 0
            strSQL = "SELECT * from tbUserVideos WHERE UserID = '{0}' AND VideoTitle = '{1}'"

            strSQL = String.Format(strSQL, pintUserID, pstrVideoTitle)

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
        Public Sub deleteUserVideo(ByVal pintVideoID As Integer)
            strSQL = "DELETE tbUserVideos WHERE VideoID =" & pintVideoID
            objCmd.CommandText = strSQL
            objCn.Open()
            objCmd.ExecuteNonQuery()
            objCn.Close()
        End Sub

        Public Function RetrieveOneUserVideo(ByVal pstrVideoID As String) As UserVideo
            Dim objAdapter As New SqlDataAdapter
            Dim objDs As New DataSet
            Dim objDataRow As DataRow
            Dim objArrayList As New ArrayList
            strSQL = "SELECT * FROM tbUserVideos WHERE VideoID = '" & pstrVideoID & "'"

            objCn.Open()

            objCmd.CommandText = strSQL
            objAdapter.SelectCommand = objCmd


            objAdapter.Fill(objDs, "tbUserVideos")
            If objDs.Tables("tbUserVideos").Rows.Count <> 0 Then
                objDataRow = objDs.Tables("tbUserVideos").Rows(0)


                Dim objUserVideo As New UserVideo

                objUserVideo.VideoID = objDataRow.Item("VideoID")
                objUserVideo.UserID = objDataRow.Item("UserID")
                objUserVideo.VideoTitle = objDataRow.Item("VideoTitle")
                objUserVideo.VideoName = objDataRow.Item("VideoName")

                objCn.Close()
                Return objUserVideo
            Else
                Return Nothing
            End If
            
        End Function

        Public Function CheckVideoTitleUpdated(ByVal pstrVideoTitle As String, ByVal pstrVideoID As String) As Boolean
            Dim intNumOfRowRetrieved As Integer
            intNumOfRowRetrieved = 0
            strSQL = "SELECT * from tbUserVideos WHERE VideoTitle = '{0}'AND VideoID !='{1}' "

            strSQL = String.Format(strSQL, pstrVideoTitle, pstrVideoID)

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

        Public Function UpDateOneVideo(ByVal objUserVideo As UserVideo) As Integer

            Dim intNumOfRecords As Integer

            strSQL = "UPDATE tbUserVideos" & _
                   " SET VideoName='" & objUserVideo.VideoName & "'," & _
                   " VideoTitle='" & objUserVideo.VideoTitle & "' WHERE VideoID =" & objUserVideo.VideoID
            objCmd.CommandText = strSQL
            objCn.Open()
            intNumOfRecords = objCmd.ExecuteNonQuery()
            objCn.Close()

            Return intNumOfRecords
        End Function
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
            
            If objDs.Tables("tbUsers").Rows.Count <> 0 Then
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
            Else
                Return Nothing
            End If
            
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
<head id="Head1" runat="server">
    <title>BabySlang - Signing Exact English (SEE) Educational Resource Website</title>
    <link id="Link1" runat="server" rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
</head>
<body>
    <form id="form1" runat="server">
    
    <!-- Begin Wrapper -->
    <div id="wrapper">
    
    <!-- Begin Sub Header 2 -->
    <div id="subheader2"><asp:Label ID="lblUserId" runat="server" Visible="false" /></div>
    <!-- End Sub Header 2 -->
    
    <!-- Begin Sub Header -->
    <div id="subheader"><h2>Upload Your Sign Language Videos</h2></div>
    <!-- End Sub Header -->
   
    <!-- Begin Navigation -->
    <div id="navigation">         
        <asp:Button id="btnChangePwd" runat="server" Text=" Change Password " Font-Names="Arial, Helvetica, sans-serif"
                    Font-Size="13px" Font-Bold="true" borderstyle="Solid" borderwidth="1px" bordercolor="#333333" BackColor="#BBE3FF" OnClick="btnChangePwd_Click" height="25px"/>
        &nbsp;
        <asp:Button id="btnLogOut" runat="server" Text=" Log Out " Font-Names="Arial, Helvetica, sans-serif"
                    Font-Size="13px" Font-Bold="true" borderstyle="Solid" borderwidth="1px" bordercolor="#333333" BackColor="#BBE3FF" OnClick="btnLogOut_Click" height="25px"/>
    </div>
    <!-- End Navigation -->
    
    <!-- Begin Sub Header -->
    <div id="subheader3">
        <h2>Welcome, <asp:Label ID="lblUserName" runat="server" />. Have fun!</h2>
    </div>
    <!-- End Sub Header -->
   
    <!-- Begin Left Column Half -->
    <div id="leftcolumn_half">
        <asp:Label CssClass="warning2" ID="lblMessage" runat="server" Font-size="Large" Visible="false"/><br /><br />
        <asp:Table ID="table5" runat="server" Width="100%">
        
            <asp:TableRow ID="tablerow2" runat="server">
                <asp:TableCell id="tablecell2" runat="server">
                    <h3>Enter Video Title: </h3>
                </asp:TableCell>
                <asp:TableCell id="tablecell3" runat="server">
                    <asp:TextBox ID="txtVideoTitle" runat="server" Font-Size="Medium" Height="25px" />
                </asp:TableCell>
            </asp:TableRow>
        
            <asp:TableRow ID="tablerow5" runat="server">
                <asp:TableCell id="tablecell4" runat="server">
                    <h3>Select Video File: </h3>
                </asp:TableCell>
                <asp:TableCell id="tablecell7" runat="server">
                    <asp:FileUpLoad id="Video" runat="server" Font-Size="Medium" Height="28px" />
                </asp:TableCell>
            </asp:TableRow>

            <asp:TableRow ID="tablerow6" runat="server">
                <asp:TableCell id="tablecell6" runat="server">
                    <asp:Label ID="Label5" runat="server" Text="(Max File Size is 4MB)"></asp:Label>
                </asp:TableCell>
                <asp:TableCell id="tablecell8" runat="server">
                    <asp:Button ID="btnAdd" runat="server" Text="Upload" Font-Size="Medium" Height="25px" Width="39%" onclick="btnAdd_click" />&nbsp;
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>   
        <br />
        <asp:GridView ID="grdVideo" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" DataKeyNames="VideoID" Width="100%" BackColor="White" Font-Size="Small" GridLines="None" 
                        BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" ShowFooter="True" ForeColor="Black" HorizontalAlign="Center" RowStyle-HorizontalAlign="Center" RowStyle-VerticalAlign="Middle" PageSize="2" AllowPaging="true" RowStyle-Height="25px" >
            <Columns>   
                <asp:BoundField DataField="VideoTitle" HeaderText="Video Title" SortExpression="VideoTitle" />
                
                <asp:BoundField DataField="VideoName" HeaderText="File Name" SortExpression="VideoName" />
                
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:Button ID="lbtnUpdate" Text="Update" CommandName="Update" CommandArgument='<%#Eval(”VideoID”) %>' runat="server" />
                    </ItemTEmplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:Button ID="lbtnDelete" Text="Delete" CommandName="Delete" CommandArgument='<%#Eval(”VideoID”) %>' runat="server" />
                    </ItemTEmplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:Button ID="btnView" Text="View" CommandName="View" CommandArgument='<%#Eval(”VideoID”) %>' runat="server" />
                    </ItemTEmplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                </asp:TemplateField>
                    
            </Columns>
            <AlternatingRowStyle BackColor="#CCFF99"/>
            <FooterStyle BackColor="#CCFF99" />
            <HeaderStyle Height="25px" BackColor="#CCFF99" />
        </asp:GridView>
    
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                            ConnectionString="Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_member;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"
                            SelectCommand="SELECT [VideoID], [VideoTitle], [VideoName] FROM [tbUserVideos] WHERE ([UserID] = @UserID)">
            <SelectParameters>
                <asp:SessionParameter Name="UserID" SessionField="UserID" Type="Int32" />
            </SelectParameters>
        </asp:SqlDataSource>
    </div>
    <!-- End Left Column -->      
  
    <!-- Begin Right Column Half-->
    <div id="rightcolumn_half">
        <!-- Media Player Object -->
        <asp:Table ID="table4" runat="server" HorizontalAlign="Center" height="290px" width= "425px" Visible="True">
            <asp:TableRow ID="tablerow3" runat="server">
                <asp:TableCell id="tablecell5" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                    <asp:Image ID="image1" runat="server" height="290px" width= "425px" Visible="true" ImageUrl="~/pictures/cms6.jpg" />
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>
        
        <asp:Table  ID="table1" runat="server" HorizontalAlign="Center" height="290px" width= "425px" Visible="False">
            <asp:TableRow ID="tablerow1" runat="server">
                <asp:TableCell id="tablecell1" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                    <object id="Object1" classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6" 
                            type="application/x-oleobject" height="290px" width="425px" align="middle"
                            codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" >                   
                        <param name="URL" value="<%=videoURL %>" />
                        <param name="enabled" value="True" />
                        <param name="AutoStart" value="True" />
                        <param name="PlayCount" value="1" />
                        <param name="Volume" value="50" />
                        <param name="balance" value="0" />
                        <param name="Rate" value="1.0" />
                        <param name="Mute" value="False" />
                        <param name="fullScreen" value="False" />
                        <param name="uiMode" value="full"/>

                        <embed type="application/x-mplayer2" src="<%=videoURL %>" name="MediaPlayer" height="290px" width="425px" align="middle"></embed>
                    </object>
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>
    </div>
   
    <!-- Begin Footer -->
    <div id="footer"><h6 align="right">Copyright BabySlang 2010</h6></div>
    <!-- End Footer -->
    </div>
    <!-- End Wrapper -->
    </form>
</body>
</html>
