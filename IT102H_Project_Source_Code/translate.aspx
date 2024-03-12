<%@ Page Language="VB" debug="true"%>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.String" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>
<script runat="server" language="vbscript">
    'Dynamic Video Playlist Variables
    Dim tmpString As Array
    Dim playlist As String
    Dim playlisturl As String
    Dim playlistfilename As String
    Dim playListStream As StreamWriter
      
    'Database Variables
    Dim sqlConn As SqlConnection
    Dim sqlCmd As SqlCommand
    Dim drTbEngWords As SqlDataReader
    
    'Boolean Variables
    Dim splitWord As Boolean
    Dim playVideo As Boolean
    
    'String Variables
    Dim input As String
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        If Request.UrlReferrer Is Nothing Then
            Response.Redirect("~/translateMain.aspx")
            Exit Sub
        End If
        'Determine whether an event is triggered within the current page or by another page
        If Not IsPostBack Then
            input = Request.QueryString("userInput") 'Retrieve the user's input in the textbox from translateMain
            LoadVideo() 'Load the video for the translated text
        End If
        Label1.Visible = False 'Hide the warning if all inputs are valid
        txtUserInput.Focus()
    End Sub
     
    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lstWords.Items.Clear() 'Clears the list in the listbox for Fingerspelling translation
        If EmptyText() Then 'Validation for empty textbox
            Label1.Text = "You have entered an empty text."
            Label1.Visible = True
            Exit Sub
        ElseIf Not ValidText() Then 'Check for non-alphabetical characters
            Label1.Text = "You have entered an invalid English word."
            Label1.Visible = True
            Exit Sub
        Else
            input = txtUserInput.Text
            Translate(input) 'Translate user's input from textbox
            
            playVideo = True 'Enable auto video streaming
        End If
        
    End Sub
    
    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtUserInput.Text = "" 'Clears txtInput textbox
        playVideo = False 'Disable auto video streaming
    End Sub
      
    Protected Sub btnFingerSpell_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        input = lstWords.SelectedValue 'Capture selected value in listbox
        FingerSpell(input) 'Fingerspell the selected word
        playVideo = True 'Enable auto video streaming
    End Sub
    
    Protected Sub Navigation_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ExitTranslate()
    End Sub
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    
    'Procedure to Load the video when webpage is invoked by translateMain.aspx
    Protected Sub LoadVideo()
        lstWords.Items.Clear() 'Clears the list in the listbox for Fingerspelling translation
        Translate(input) 'Translate user's input from textbox
        playVideo = True 'Enable auto video streaming 
    End Sub
    
    Protected Sub Translate(ByVal tinput As String) 'Create dynamic playlist for a valid word or phrase
        
        Dim tmpInput As String
        
        tmpInput = tinput 'Assign value to temporary variable
        
        'Removes valid punctuation marks
        tmpInput = tmpInput.Replace("!", "")
        tmpInput = tmpInput.Replace(",", "")
        tmpInput = tmpInput.Replace(".", "")
        tmpInput = tmpInput.Replace("?", "")
        
        tmpString = tmpInput.Split(" ") 'Split the text input into an array of single words and assign to temporary array
        
        tmpInput = tmpInput.Replace(" ", "") 'Remove space in temporary input to create a filename for the playlist
        
        playlistfilename = tmpInput & DateTime.Now.ToString("yyyyMMddhhmmssffffff") & ".m3u" 'Adding a unique value and file extension to playlist file
        playlisturl = "http://www.babyslang.net/playlist/" & playlistfilename 'Create the URL to locate the playlist file
        
        'Open a file for writing
        'Retrieve the physical full path of directory where the file is located in the web server
        playlist = Server.MapPath("~/playlist/" & playlistfilename)
        
        'Get a StreamWriter object that can be used to write to the file 
        playListStream = File.CreateText(playlist)
        
        'Connect to Database
        ConnectDB()
        input = ""
        'For Loop to write tmpString array values into playlist file
        For i As Integer = 0 To UBound(tmpString)
            If FoundInDB("SELECT WORD, VIDEO FROM tbEngWords WHERE WORD ='" & tmpString(i) & "'") Then
                playListStream.WriteLine("http://www.babyslang.net/videoscap/" & drTbEngWords(1).ToString)
                input += " " & tmpString(i)
            Else
                lstWords.Items.Add(tmpString(i).ToString)
            End If
            drTbEngWords.Close() 'Close the Datareader
        Next
        'Close the DB connection
        sqlConn.Close()
        'Close the stream
        playListStream.Close()
    End Sub
    
    Protected Sub FingerSpell(ByVal finput As String)
      
        Dim tmpInput As String
        
        tmpInput = finput 'Assign value to temporary variable
        tmpString = finput.ToCharArray 'Split the word into an array of single characters and assign to temporary array
        
        playlistfilename = tmpInput & DateTime.Now.ToString("yyyyMMddhhmmssffffff") & "f.m3u" 'Adding a unique value and file extension to playlist file
        playlisturl = "http://www.babyslang.net/playlist/" & playlistfilename 'Create the URL to locate the playlist file

        'Open a file for writing
        'Retrieve the physical full path of directory where the file is located in the web server
        playlist = Server.MapPath("~/playlist/" & playlistfilename)
        
        'Get a StreamWriter object that can be used to write to the file 
        playListStream = File.CreateText(playlist)
        
        'Connect to Database
        ConnectDB()
        'For Loop to write tmpString array values into playlist file
        For i As Integer = 0 To UBound(tmpString)
            If FoundInDB("SELECT ALPHABET, VIDEO FROM tbAlphabet WHERE ALPHABET ='" & tmpString(i) & "'") Then
                playListStream.WriteLine("http://www.babyslang.net/videoscap/" & drTbEngWords(1).ToString)
            End If
            drTbEngWords.Close() 'Close the Datareader
        Next
        sqlConn.Close()
        'Close the stream
        playListStream.Close()
        'playlist = "http://www.babyslang.net/playlist.m3u"
    End Sub
    
    'Procedure to Connect to Database
    Protected Sub ConnectDB()
        sqlConn = New SqlConnection("Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200")
        sqlConn.Open()
    End Sub
    
    'Procedure to Check Whether Input Exists in the Database
    Protected Function FoundInDB(ByVal sqlStatement As String) As Boolean
        Dim tmpStatement As String
            
        'Assign sqlCmd to tmpCmd                           
        tmpStatement = sqlStatement
        
        sqlCmd = New SqlCommand(tmpStatement, sqlConn)
        
        'executing the command and assigning it to connection 
        drTbEngWords = sqlCmd.ExecuteReader()
       
        'reading from the datareader
        If drTbEngWords.HasRows Then 'Check if a row exists
            drTbEngWords.Read() 'Read the first row
            Return True
        Else
            Return False
        End If
    End Function
    
    'Procedure to Check for empty input
    Protected Function EmptyText() As Boolean
        If txtUserInput.Text = "" Then
            Return True
        Else
            Return False
        End If
    End Function
    
    'Procedure to Check for valid input
    Protected Function ValidText() As Boolean
        Dim num As Integer
        Dim tmpString As String
   
        tmpString = txtUserInput.Text 'Assign value to temporary variable
        
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
        num += InStr(tmpString, "%")
        
        num += InStr(tmpString, "1")
        num += InStr(tmpString, "2")
        num += InStr(tmpString, "3")
        num += InStr(tmpString, "4")
        num += InStr(tmpString, "5")
        num += InStr(tmpString, "6")
        num += InStr(tmpString, "7")
        num += InStr(tmpString, "8")
        num += InStr(tmpString, "9")
        num += InStr(tmpString, "0")

        If num = 0 Then
            Return True 'Return True if none of the characters are found
        Else
            Return False 'Return False if the characters are found
        End If
    End Function
    
    'Procedure to release resources when the page is navigated to another page
    Protected Sub ExitTranslate()
        drTbEngWords.Close()
        sqlConn.Close()
        sqlConn.Dispose()
        Session.Clear()
        Session.Abandon()
    End Sub
    ''''''''''''''''''''''''''''''''''''''''''''' End of Script ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BabySlang - Signing Exact English (SEE) Educational Resource Website</title>
    
    <link runat="server" rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
</head>
<body>
    <form id="form1" runat="server">
    
    <!-- Begin Wrapper -->
    <div id="wrapper">

    <!-- Begin Sub Header 2 -->
    <div id="subheader2"></div>
    <!-- End Sub Header 2 -->

    <!-- Begin Sub Header -->
    <div id="subheader"><h2>Translate to SEE</h2></div>
    <!-- End Sub Header --> 
  
    <!-- Begin Navigation -->
    <div id="navigation">
        <ul id="Menu">
            <li><a href="http://www.babyslang.net/aboutus.aspx" onclick="Navigation_Click"><span>About Us</span></a></li>
            <li><a href="http://www.babyslang.net/Register.aspx"><span>Register</span></a></li>
            <li><a href="http://www.babyslang.net/Login.aspx"><span>Log In</span></a></li>
            <li><a href="http://www.babyslang.net/quiz.aspx" onclick="Navigation_Click"><span>Fun Quiz</span></a></li>
            <li><a href="http://www.babyslang.net/learnithome.aspx"onclick="Navigation_Click"><span>Learn SEE</span></a></li>
            <li><a href="http://www.babyslang.net/home.aspx"onclick="Navigation_Click"><span>Home</span></a></li>
        </ul>
    </div>
    <!-- End Navigation -->

    <!-- Begin Sub Header 3 -->
    <div id="subheader3"><h2>English Word or Phrase to be Translated to SEE: "<%= LTrim(UCase(input))%>"</h2></div>
    <!-- End Sub Header 3 -->

    <!-- Begin Left Column Half -->
    <div id="leftcolumn_half">
        <h4>Please enter another English word or phrase and click Translate. <asp:Label cssclass="warning2" ID="Label1" runat="server" Text="Label"></asp:Label></h4><br />
        <asp:TextBox ID="txtUserInput" runat="server" Width="100%" Height="25px"></asp:TextBox>
        <asp:Button ID="btnSubmit" runat="server" onclick="btnSubmit_Click" Text="Translate" />   
        <asp:Button ID="btnClear" runat="server" onclick="btnClear_Click" Text="Clear" />
        <br /><br />
        <h4>Words listed below are too complex for the child and are not included in the system. Please click the word in the list for the Finger Spelling translation.</h4>
        <br />
        <asp:ListBox ID="lstWords" runat="server" Height="80px" Width="100%"></asp:ListBox>
        <asp:Button ID="btnFingerSpell" runat="server" onclick="btnFingerSpell_Click" Text="Fingerspell" />    
    </div>
    <!-- End Left Column -->
  
    <!-- Begin Right Column Half -->
    <div id="rightcolumn_half">
        <asp:Table  ID="table1" runat="server" HorizontalAlign="Center" height="290px" width= "425px">
            <asp:TableRow ID="tablerow1" runat="server">
                <asp:TableCell id="tablecell1" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                    <object id="VIDEO" classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6" 
                        type="application/x-oleobject" height="290px" width="425px" align="middle" 
                        codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" >                   
                        <param name="URL" value="<%=playlisturl %>" />
                        <param name="enabled" value="True"/>
                        <param name="AutoStart" value="<%=playVideo %>" />
                        <param name="PlayCount" value="1" />
                        <param name="Volume" value="50" />
                        <param name="balance" value="0" />
                        <param name="Rate" value="1.0" />
                        <param name="Mute" value="False" />
                        <param name="fullScreen" value="False" />
                        <param name="uiMode" value="full" />

                        <embed type="application/x-mplayer2" src="<%=playlisturl %>" name="MediaPlayer" height="290px" width="425px" align="middle"></embed>
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
