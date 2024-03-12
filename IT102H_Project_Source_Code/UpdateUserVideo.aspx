<%@ Page Language="vb" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script type="text/javascript" language="javascript">

     window.history.forward(1);

</script>  
<script runat="server" language="vbscript">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        'Check if page is referred after user is authenticated at log in
        'Redirect user to log in if not from log in page
        If Request.UrlReferrer Is Nothing Then
            Response.Redirect("~/Login.aspx")
            Exit Sub
        End If
        
        Dim objDBUserVideo As New DBUserVideo
        Dim objUserVideo As New UserVideo

        Dim strEmail As String

        strEmail = Session("UserEmail")
        Me.lblUserId.Text = Session("UserID")
        'Check if page is triggered by a postback event
        If Page.IsPostBack = False Then
            Dim intRecordId As Integer

            'binding the videoid into intRecordId
            intRecordId = Request.QueryString("id")
            'retriving the chosen video by calling the 	DBVideo class function
            objUserVideo = objDBUserVideo.RetrieveOneUserVideo(intRecordId)
            Me.txtVideoTitle.Text = objUserVideo.VideoTitle
            Me.lblVideoName.Text = objUserVideo.VideoName

            'populate
            ViewState("Videotitle") = Me.txtVideoTitle.Text
            ViewState("Videoname") = Me.lblVideoName.Text
            ViewState("VideoId") = intRecordId
        End If
    End Sub

    'Procedure to update the video title, video filename or both of the current video
    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim objDBUserVideo As New DBUserVideo
        Dim objUserVideo As New UserVideo
        Dim intNumOfRecord As Integer
        Dim upload As New FileClass
        Dim videoFileDirectory As String
        Dim videoFullPath As String
        
        If txtVideoTitle.Text.Trim.Length > 80 Then
            lblMessage.Text = "Please Enter a Shorter Video Title."
            lblMessage.Visible = True
            txtVideoTitle.Focus()
            Exit Sub
        End If
            
        If Not ValidText(txtVideoTitle.Text) Then 'Check if the input contains disallowed characters
            lblMessage.Text = "Please Enter ONLY Alphanumeric Characters for the Video Title."
            lblMessage.Visible = True
            txtVideoTitle.Focus()
            Exit Sub
        End If
        
        If Video.HasFile And Not ValidFile(Video.FileName) Then
            lblMessage.Text = "Only .asf, .wmv, .wm, .avi, .mpe, .mpeg, .mpg, .m1v  files are accepted."
            lblMessage.Visible = True
            Video.Focus()
            Exit Sub
        End If
        
        If Video.FileName.Length > 80 Then 'Check if the video filename is more than 80 characters
            lblMessage.Text = "Your Video Filename is too long. Please Change to a Shorter Name." 'Inform user if video filename is more than 80 characters long
            lblMessage.Visible = True
            Video.Focus()
            Exit Sub
        End If
        
        If Not Video.HasFile Then 'Check if a new video file is selected
            'use back the old video file if no new file is selected, only the video title is updated
            objUserVideo.VideoName = ViewState("Videoname") 'Assign the current video filename to the object if no new video file is selected
        Else
            objUserVideo.VideoName = Video.FileName
        End If
        
        'Check if the textbox is  empty
        If txtVideoTitle.Text = "" Then
            objUserVideo.VideoTitle = ViewState("Videotitle") 'Assign the current video title to the object if no new video title is given
        Else
            'get the value from the textboxes  
            objUserVideo.VideoTitle = Me.txtVideoTitle.Text
        End If
        
        'get the value from the QueryString
        objUserVideo.VideoID = Request.QueryString("id")
        
        objUserVideo.UserID = Me.lblUserId.Text.Trim
        'objUserVideo.VideoTitle = Me.txtVideoTitle.Text.Trim
       
        'update the database
        intNumOfRecord = objDBUserVideo.UpDateOneVideo(objUserVideo)
        
        If Video.HasFile Then
            videoFileDirectory = Server.MapPath("~/") & "membervideos\" & lblUserId.Text & "\" 'Create the directory path in the web server
            videoFullPath = videoFileDirectory & Video.FileName 'Create the full path in the web server
            Video.SaveAs(videoFullPath) 'Upload the video file to the web server
        End If
                 
        Response.Redirect("~/maintainuservideo.aspx?updated=1")

    End Sub

    'Procedure to redirect the user back to maintain user video if he/she does not want to continue to update
    Protected Sub btnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/maintainuservideo.aspx?id=" & lblUserId.Text)
    End Sub
    
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
    
    'Procedure to check for disallowed characters in text input
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
        num += InStr(tmpstring, "!")
        num += InStr(tmpstring, ",")
        num += InStr(tmpstring, ".")
        num += InStr(tmpstring, "?")
        
        
        
        If num = 0 Then
            Return True 'Return True if none of the characters are found
        Else
            Return False 'Return False if the characters are found
        End If
    End Function
    
    ''''''''''''''''''''''''''''''''''''''''Class Objects''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

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
	
	'Insert a new row in the tbUsers table
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
        'Check number of uploaded videos
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
        'Check whether if video title already exist
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
	'Delete a video record from the database
        Public Sub deleteUserVideo(ByVal pintVideoID As Integer)
            strSQL = "DELETE tbUserVideos WHERE VideoID =" & pintVideoID
            objCmd.CommandText = strSQL
            objCn.Open()
            objCmd.ExecuteNonQuery()
            objCn.Close()
        End Sub
	'Retrieve a video record from the database
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
            objDataRow = objDs.Tables("tbUserVideos").Rows(0)


            Dim objUserVideo As New UserVideo

            objUserVideo.VideoID = objDataRow.Item("VideoID")
            objUserVideo.UserID = objDataRow.Item("UserID")
            objUserVideo.VideoTitle = objDataRow.Item("VideoTitle")
            objUserVideo.VideoName = objDataRow.Item("VideoName")

            objCn.Close()
            Return objUserVideo

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
		'Update one database record
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

    Public Class FileClass

        Private strDBURL As String
        Public strExactURL As String
        Dim rootFolder As String
        
	'Procedure to upload file to the server
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
            strDBURL = strFileNameOnly 'strUnitNo.Trim & "/" & strType.Trim & "/" & strTypeName.Trim & "/" & 

        End Sub
	'Procedure to delete a video file
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
<head id="Head1" runat="server">
    <title>BabySlang - Signing Exact English (SEE) Educational Resource Website</title>
    <link id="Link1" runat="server" rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
</head>
<body>
    <form id="form1" runat="server">      

    <!-- Begin Wrapper -->
    <div id="wrapper">
    
    <!-- Begin Sub Header 2 -->
    <div id="subheader2">
        <asp:Label ID="lblUserId" runat="server" Visible="false" /><asp:Label ID="lblUserName" runat="server" Visible="false" />
        <asp:Label ID="lblVideoName" runat="server" visible="false"/>
    </div>
    <!-- End Sub Header 2 -->
        
    <!-- Begin Sub Header -->
    <div id="subheader"><h2>Update Video</h2></div>
    <!-- End Sub Header -->
    
    <!-- Begin Navigation -->
    <div id="navigation">
    </div>
    <!-- End Navigation -->
    
    <!-- Begin Sub Header -->
    <div id="subheader3">
        <h2>Please Enter a New Video Title or Select a New Video File and Click Update</h2>
    </div>
    <!-- End Sub Header -->
   
    <!-- Begin Left Column Half -->
    <div id="leftcolumn_half">
        <br />
        <asp:Table ID="table1" runat="server" Height="70px">
            <asp:TableRow ID="tablerow1" runat="server">
                <asp:TableCell id="tablecell1" runat="server">
                    <asp:Label ID="Label1" runat="server" Text="Current Video Title: " Font-Size="Large"></asp:Label>
                </asp:TableCell>
                <asp:TableCell id="tablecell6" runat="server" Font-Size="Large">
                    &nbsp;<%=viewstate("Videotitle") %>
                </asp:TableCell>
            </asp:TableRow>

            <asp:TableRow ID="tablerow4" runat="server">
                <asp:TableCell id="tablecell9" runat="server">
                    <asp:Label ID="Label2" runat="server" Text="Current Video File: " Font-Size="Large"></asp:Label>
                </asp:TableCell>
                <asp:TableCell id="tablecell10" runat="server" Font-Size="Large">
                    &nbsp;<%= ViewState("Videoname")%>
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>
        <br />
        <asp:Label CssClass="warning2" ID="lblMessage" runat="server" Font-size="Large" Visible="false"/>
        <br /><br />
        <asp:Table ID="table5" runat="server" Width="425px" Height="110px">
            <asp:TableRow ID="tablerow2" runat="server">
                <asp:TableCell id="tablecell2" runat="server">
                    <asp:Label ID="Label4" runat="server" Text="New Video Title: " Font-Size="Large"></asp:Label>
                </asp:TableCell>
                <asp:TableCell id="tablecell3" runat="server">
                    <asp:TextBox ID="txtVideoTitle" runat="server" Font-Size="Medium" Height="25px"/>
                </asp:TableCell>
            </asp:TableRow>
            <asp:TableRow ID="tablerow5" runat="server">
                <asp:TableCell id="tablecell4" runat="server">
                    <asp:Label ID="Label3" runat="server" Text="New Video File: " Font-Size="Large"></asp:Label>
                </asp:TableCell>
                <asp:TableCell id="tablecell7" runat="server">
                    <asp:FileUpLoad id="Video" runat="server" Font-Size="Medium" Height="28px"/>
                </asp:TableCell>
            </asp:TableRow>

            <asp:TableRow ID="tablerow6" runat="server">
                <asp:TableCell id="tablecell8" runat="server">
                    <asp:Label ID="Label5" runat="server" Text="(Max File Size is 4MB)"></asp:Label>
                </asp:TableCell>
                <asp:TableCell id="tablecell11" runat="server">
                    <asp:Button ID="btnUpdate" runat="server" Text=" Update " Font-Size="Medium" Height="25px" OnClick="btnUpdate_Click" />&nbsp
                    <asp:Button ID="btnCancel" runat="server" Text=" Cancel " Font-Size="Medium" Height="25px" OnClick="btnBack_Click" />
                </asp:TableCell>
           </asp:TableRow>
        </asp:Table>
    </div>
    <!-- End Left Column -->      
  
    <!-- Begin Right Column Half-->
    <div id="rightcolumn_half">
       
    <asp:Table ID="table4" runat="server" HorizontalAlign="Center" height="290px" width= "425px" Visible="True">
        <asp:TableRow ID="tablerow3" runat="server">
            <asp:TableCell id="tablecell5" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                <asp:Image ID="image1" runat="server" height="290px" width= "425px" Visible="true" ImageUrl="~/pictures/cms6.jpg" />
            </asp:TableCell>
        </asp:TableRow>
    </asp:Table>
    </div>
    <!-- End Right Column Half-->

    <!-- Begin Footer -->
    <div id="footer">
        <h6 align="right">Copyright BabySlang 2010</h6>
    </div>
    <!-- End Footer -->    
    </div>
    <!-- End Wrapper -->
    </form>
</body>
</html>
