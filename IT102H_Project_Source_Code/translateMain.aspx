<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>
<script runat="server" language="vbscript">

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        If EmptyText() Then 'Validation for empty textbox
            Label1.Text = "You have entered an empty text."
            Label1.Visible = True
            Exit Sub
        ElseIf Not ValidText() Then 'Check for non-alphabetical characters
            Label1.Text = "You have entered an invalid English word or invalid characters."
            Label1.Visible = True
            Exit Sub
        Else
            Response.Redirect("~/translate.aspx?userInput=" & txtUserInput.Text) 'Redirect to translate with userInput value
        End If
    End Sub
    
    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtUserInput.Text = "" 'Clears txtInput textbox
    End Sub
    
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
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        txtUserInput.Focus()
        Label1.Visible = False 'Hide the warning if all inputs are valid
        
    End Sub
    '''''''''''''''''''''''''''''''''''''''' End of Script'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BabySlang - Signing Exact English (SEE) Educational Resource Website</title>
    <link rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
</head>
<body runat="server">
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
    <div id="navigation" > 
        <ul id="Menu">
            <li><a href="http://www.babyslang.net/aboutus.aspx"><span>About Us</span></a></li>
            <li><a href="http://www.babyslang.net/Register.aspx"><span>Register</span></a></li>
            <li><a href="http://www.babyslang.net/Login.aspx"><span>Log In</span></a></li>
            <li><a href="http://www.babyslang.net/quiz.aspx"><span>Fun Quiz</span></a></li>
            <li><a href="http://www.babyslang.net/learnithome.aspx"><span>Learn SEE</span></a></li>
            <li><a href="http://www.babyslang.net/home.aspx"><span>Home</span></a></li>
        </ul>
    </div>
    <!-- End Navigation -->

    <!-- Begin Sub Header 3 -->
    <div id="subheader3"><h2>Please Enter an English Word or Phrase Below and Click Translate</h2></div>
    <!-- End Sub Header 3 -->
  
    <!-- Begin Merge Column -->
    <div id="translatemergecolumn">
    <asp:Table ID="table1" runat="server" Width="900px" Height="300px" BackColor="White">
        <asp:TableRow ID="tablerow1" runat="server" Width="900px" Height="180px">
            <asp:TableCell ID="tablecell1" runat="server" Width="900px" Height="180px">
                <asp:Image ID="Image1" runat="server" ImageUrl="~/pictures/translate4.jpg"/>
            </asp:TableCell>
        </asp:TableRow>
        <asp:TableRow ID="tablerow2" runat="server" Width="900px" Height="120px">
            <asp:TableCell ID="tablecell2" runat="server" Width="900px" Height="120px"><h3>
                <asp:Label cssclass="warning" ID="Label1" runat="server"></asp:Label></h3><br />  
                <asp:TextBox ID="txtUserInput" runat="server" Width="50%" Height="28px" 
                            align="center" Font-Size="Large"></asp:TextBox><br /><br />
            <asp:Button ID="btnSubmit" runat="server" onclick="btnSubmit_Click" 
                        Text=" Translate " Font-Size="Large" />&nbsp;   
            <asp:Button ID="btnClear" runat="server" onclick="btnClear_Click" Text=" Clear " 
                        Font-Size="Large" /></asp:TableCell>
        </asp:TableRow>
    </asp:Table>     
  </div>
    <!-- End Merge Column -->

    <!-- Begin Footer -->
    <div id="footer"><h5 align="right">Copyright BabySlang 2010</h5></div>
    <!-- End Footer -->
    
    </div>
    <!-- End Wrapper -->
    </form>
</body>
</html>
