<%@ Page Language="VB" Debug="true" %>

<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.String" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>

<script runat="server" language="vbscript">
    
    'Boolean Variable
    Dim startVideo As Boolean
    
    'Url of the video to be played
    Dim videoURL As String
     
    'Database Variables
    Dim sqlConn As SqlConnection
    Dim sqlCmd As SqlCommand
    Dim drTbQuiz As SqlDataReader
    Dim drTbEngWords As SqlDataReader
    Dim sqlStatement As String
    
    'ArrayList Variables
    Dim ansList As New ArrayList
    Dim qnList As New ArrayList
    
    'Variable to capture users' choice from Quiz menu
    Dim input As String
    
    Dim score As Integer
    
    'Function that generate 5 unique random digits between 1 to 10
    'For each theme, there are 10 qns stored in the DB
    'However the quiz will only retrieve 5 qns out of the 10 qns stored in DB
    Protected Function RandomQn() As ArrayList
        Dim r As New Random
        Dim index As Integer
        Dim numList As New ArrayList
        index = 0

        For i As Integer = 1 To 10 'Generate a list of numbers 1 to 10
            numList.Add(i)
        Next
        
        For i As Integer = 1 To 5 'Removes 5 numbers from numList Array at random index
            index = r.Next(11 - i)
            numList.RemoveAt(index)
        Next
        
        Return numList 'Return an array list of 5 random numbers between 1 to 10
    End Function

    'Function that generate 3 unique random digits between 1 to 3
    Protected Function RandomAns() As ArrayList
        'An object of Random
        Dim r As New Random
        Dim index As Integer

   
        Dim numList1 As New ArrayList
        Dim numList2 As New ArrayList

        index = 0

        For i As Integer = 1 To 3 'Generate a list of numbers 1 to 3

            numList1.Add(i)
        Next

        For i As Integer = 1 To 3
            index = r.Next(4 - i)

            numList2.Add(numList1.Item(index)) 'Add number from numList Array at random index

            numList1.RemoveAt(index) 'Removes number from numList1 Array at random index
        Next

        Return numList2 'Return an array list of 3 random numbers from 1 to 3
    End Function
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        'Determine whether the current page is referred by another page or access directly through URL
        If Request.UrlReferrer Is Nothing Then
            Response.Redirect("~/quiz.aspx")
            Exit Sub
        End If
        
        input = Request.QueryString("userInput")
        If Not IsPostBack Then 'Determine whether a post back event is triggered
            qnList = RandomQn()
            Session("qn") = qnList
            Session("score") = 0
            Session("userQn") = 0
            
            Qn.Text = "Qn1: What does the following sign means?"
            
            RetrieveQn(Session("qn")(0))
        End If
    End Sub
    
    'Procedure to connect to database
    Protected Sub ConnectDB()
        sqlConn = New SqlConnection("Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200")
        sqlConn.Open()
    End Sub
    
    'Procedure to generate the next question
    Protected Sub NextQnBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        VerifyAns(Session("qn")(Session("userQn")))
        Session("userQn") += 1
     
        Qn.Text = "Qn" & Session("userQn") + 1 & ": What does the following sign means?"
   
        RetrieveQn(Session("qn")(Session("userQn")))
        
        'Reset all the radio button to unchecked
        AnsBtn1.Checked = False
        AnsBtn2.Checked = False
        AnsBtn3.Checked = False
        
        If (Session("userQn") >= 4) Then 'Determine whether user is at the last question
            NextQnBtn.Visible = False
            SubmitBtn.Visible = True
        End If
    End Sub
    
    'Procedure to verify quiz answers
    Protected Sub VerifyAns(ByVal input_QnNum As Integer)
        ConnectDB()
        sqlStatement = "SELECT QnNum, CorrectAnsWordID FROM tbQuiz WHERE Theme ='" & input & "' AND QnNum =" & input_QnNum.ToString & ";"
        sqlCmd = New SqlCommand(sqlStatement, sqlConn)
        
        drTbQuiz = sqlCmd.ExecuteReader()
        drTbQuiz.Read()
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        
        sqlStatement = "SELECT WORD FROM tbEngWords WHERE WORDID=" & drTbQuiz(1) & ";"
        
        sqlCmd = New SqlCommand(sqlStatement, sqlConn)
        drTbEngWords = sqlCmd.ExecuteReader()
        drTbEngWords.Read()
        
        'IF/ELSE statement to check through all the radio buttons and add score if correct answer is chosen
        If (AnsBtn1.Checked = True) Then
            If (AnsBtn1.Text.Trim = drTbEngWords(0)) Then
                Session("score") += 20
            End If
        ElseIf (AnsBtn2.Checked = True) Then
            If (AnsBtn2.Text.Trim = drTbEngWords(0)) Then
                Session("score") += 20
            End If
        ElseIf (AnsBtn3.Checked = True) Then
            If (AnsBtn3.Text.Trim = drTbEngWords(0)) Then
                Session("score") += 20
            End If
        End If
        drTbEngWords.Close()
        drTbQuiz.Close()
        sqlConn.Close()
        sqlConn.Dispose()
    End Sub
   
    'Procedure to calculate total score after quiz is completed and inform user on the scores
    Protected Sub SubmitBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        VerifyAns(Session("qn")(Session("userQn")))
        AnsBtn1.Visible = False
        AnsBtn2.Visible = False
        AnsBtn3.Visible = False
        SubmitBtn.Visible = False
        Qn.Text = ("Your Score is: " & Session("score"))
        
        If Session("score") < 50 Then
            Qn.Text += ". Don't Give Up! You can do it!"
            btnRevise.Visible = True
        ElseIf Session("score") < 60 Then
            Qn.Text += ". Good! Keep it Up!."
            btnTryAgain.Visible = True
        ElseIf Session("score") < 80 Then
            Qn.Text += ". Very Good! Keep it Up!"
            btnTryAgain.Visible = True
        Else
            Qn.Text += ". Excellent! Keep it Up!"
            btnTryAgain.Visible = True
        End If
        ExitQuiz()
    End Sub
      
    'Retrieve qn from DB, the input to be passed in will be the random no. stored in the array
    Protected Sub RetrieveQn(ByVal input_QnNum As Integer)
        ConnectDB()
        sqlStatement = "SELECT QnNum, CorrectAnsWordID, WrongAnsWordID1, WrongAnsWordID2 FROM tbQuiz WHERE Theme ='" & input & "' AND QnNum =" & input_QnNum.ToString & ";"
        sqlCmd = New SqlCommand(sqlStatement, sqlConn)
        
        drTbQuiz = sqlCmd.ExecuteReader()
        
        drTbQuiz.Read()
        
        ansList = RandomAns()
        
        sqlStatement = "SELECT WORD FROM tbEngWords WHERE WORDID=" & drTbQuiz(ansList.Item(0)) & ";"
        
        sqlCmd = New SqlCommand(sqlStatement, sqlConn)
        
        'executing the command and assigning it to connection
        drTbEngWords = sqlCmd.ExecuteReader()
        
        drTbEngWords.Read()
        AnsBtn1.Text = " " & drTbEngWords(0)
        drTbEngWords.Close()
                
        sqlStatement = "SELECT WORD FROM tbEngWords WHERE WORDID=" & drTbQuiz(ansList.Item(1)) & ";"
        sqlCmd = New SqlCommand(sqlStatement, sqlConn)
        
        'executing the command and assigning it to connection 
        drTbEngWords = sqlCmd.ExecuteReader()
        
        drTbEngWords.Read()
        AnsBtn2.Text = " " & drTbEngWords(0)
        drTbEngWords.Close()
        
        sqlStatement = "SELECT WORD FROM tbEngWords WHERE WORDID=" & drTbQuiz(ansList.Item(2)) & ";"
        sqlCmd = New SqlCommand(sqlStatement, sqlConn)
        
        'executing the command and assigning it to connection 
        drTbEngWords = sqlCmd.ExecuteReader()
        
        drTbEngWords.Read()
        AnsBtn3.Text = " " & drTbEngWords(0)
        drTbEngWords.Close()
        
        PlayVideo(drTbQuiz(1))
        
        drTbQuiz.Close()
        sqlConn.Close()
        sqlConn.Dispose()
    End Sub
    
    'Procedure to play video when question is shown
    Protected Sub PlayVideo(ByVal correctAnsWordID As String)

        sqlStatement = "SELECT WORD, VIDEO FROM tbEngWords WHERE WORDID=" & correctAnsWordID & ";"
        sqlCmd = New SqlCommand(sqlStatement, sqlConn)
        
        'executing the command and assigning it to connection 
        drTbEngWords = sqlCmd.ExecuteReader()
        
        drTbEngWords.Read()
        
        videoURL = "http://www.babyslang.net/videos/" & drTbEngWords(1)
        startVideo = True
        
        drTbEngWords.Close()
    End Sub
    
    'Procedure to display the correct theme
    Protected Function Label() As String
        If input = "other" Then
            Return "Simple SEE"
        ElseIf input = "family" Then
            Return "Family"
        ElseIf input = "month" Then
            Return "Calendar"
        Else
            Return "Zoo"
        End If
    End Function
   
    'Procedure to close session variables and release resources when user exit the quiz
    Protected Sub ExitQuiz()
        Session("score") = 0
        Session("userQn") = 0
        ansList.Clear()
        qnList.Clear()
        Session.Clear()
        Session.Abandon()
    End Sub

    Protected Sub btnExit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ExitQuiz()
        Response.Redirect("~/home.aspx")
    End Sub

    Protected Sub btnTryAgain_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ExitQuiz()
        Response.Redirect("~/quiz.aspx")
    End Sub

    Protected Sub btnRevise_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ExitQuiz()
        'Directs user to the correct learning page relating to the theme of the quiz taken        
        If input = "other" Then
            Response.Redirect("~/ViewLearnIt.aspx?id=90")
        ElseIf input = "family" Then
            Response.Redirect("~/ViewLearnIt.aspx?id=33")
        ElseIf input = "month" Then
            Response.Redirect("~/ViewLearnIt.aspx?id=21")
        Else
            Response.Redirect("~/ViewLearnIt.aspx?id=49")
        End If
        
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>BabySlang.net - Signing Exact English (SEE) Educational Resource Website</title>
    <link rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
    
</head>
<body>
    <form id="form1" runat="server">
    
    <div id="wrapper">

    <!-- Begin Sub Header 2 -->
    <div id="subheader2"></div>
    <!-- End Sub Header 2 -->

    <!-- Begin Sub Header -->
    <div id="subheader"><h2><%= Label()%> Quiz Questions</h2></div>
    <!-- End Sub Header -->
   
    <!-- Begin Sub Header -->
    <div id="subheader3"><h2>Please Choose an Answer and Click Next</h2></div>
    <!-- End Sub Header -->

    <!-- Quiz Column -->
    <div id="leftcolumn_half">
        <h2><asp:Label ID="Qn" runat="server"></asp:Label></h2>
        <br /><br />
        <asp:Button ID="btnTryAgain" runat="server" Text=" Try Other Themes " Font-Size="Large" Visible="false" OnClick="btnTryAgain_Click" />
        <asp:Button ID="btnRevise" runat="server" Text=" Take a Revision " Font-Size="Large" Visible="false" onclick="btnRevise_Click"/>
        <asp:RadioButton ID="AnsBtn1" runat="server" GroupName="Answer" Font-Size="Large"></asp:RadioButton>
        <br /><br />
        <asp:RadioButton ID="AnsBtn2" runat="server" GroupName="Answer" Font-Size="Large">
        </asp:RadioButton>
        <br /><br />
        <asp:RadioButton ID="AnsBtn3" runat="server" GroupName="Answer" Font-Size="Large">
        </asp:RadioButton>
        <br /><br />
        <asp:Button ID="NextQnBtn" OnClick="NextQnBtn_Click" runat="server" Text=" Next " Font-Size="Large"/>
        <asp:Button ID="SubmitBtn" OnClick="SubmitBtn_Click" runat="server" Text=" Submit " Visible="False" Font-Size="Large" />
        <br /><br /><br />                               
    </div>
    <!-- End Left Column -->
  
    <!-- Begin Right Column Half -->
    <div id="rightcolumn_half">
        <asp:Table  ID="table1" runat="server" HorizontalAlign="Center" height="290px" width= "425px">
            <asp:TableRow ID="tablerow2" runat="server">
                <asp:TableCell id="tablecell3" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                    <object id="Object1" classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6" 
                        type="application/x-oleobject" height="290px" width="425px" align="middle"
                        codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" >                   
                        <param name="URL" value="<%=videoURL %>" />
                        <param name="enabled" value="True" />
                        <param name="AutoStart" value="<%=startVideo %>" />
                        <param name="PlayCount" value="1" />
                        <param name="Volume" value="50" />
                        <param name="balance" value="0" />
                        <param name="Rate" value="1.0" />
                        <param name="Mute" value="False" />
                        <param name="fullScreen" value="False" />
                        <param name="uiMode" value="full" />
                        <embed type="application/x-mplayer2" src="<%=videoURL %>" name="MediaPlayer" height="290px" width="425px" align="middle"></embed>
                    </object>
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>  
    </div>

    <!-- Begin Navigation -->
    <div id="navigation" > 
    <h3>To Exit the Quiz, Click <asp:Button ID="btnExit" OnClick="btnExit_Click" runat="server" Text=" Exit " Visible="true" Font-Size="Large" /></h3>
    </div>
    <!-- End Navigation -->

    <!-- Begin Footer -->
    <div id="footer"><h5 align="right">Copyright BabySlang 2010</h5></div>
    <!-- End Footer -->
    </div>
    <!-- End Wrapper -->
    </form>
</body>
</html>
