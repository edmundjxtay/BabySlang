<%@ Page Language="vb" Debug="true"%>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>
<script runat="server" language="vbscript" >
    
    'String Variables
    Dim strVideoPath As String
    Dim strVideoURL As String
    
    'Object Variables
    Dim objDBWord As New DBWord
    Dim objWord As New Word
    
    'Boolean Variables
    Dim startVideo As Boolean
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        'Determine whether the current page is referred by another page or access directly through URL
        If Request.UrlReferrer Is Nothing Then
            Response.Redirect("~/home.aspx")
            Exit Sub
        End If
        
        startVideo = False 'Disable auto video streaming by default       
        Me.listTheme.Visible = True
        
        If Not IsPostBack Then 'Determine whether an event is triggered within the current page or by another page
            If Not Request.QueryString("Id") Is Nothing Then 'check if there is nothing in query string
                Dim intRecordId As String
                'binding the floorid into intRecordId
                intRecordId = Request.QueryString("Id")
                'retriving the chosen floor by calling the DBFloor class function
                objWord = objDBWord.RetrieveOneWord(intRecordId)

                Me.Label1.Text = objWord.WordName 'Assign the retreived word value to the label for temporary storage
                DropDownList1.Text = objWord.WordName 'Setting the selected value of the dropdown list to be the same the retrieved word value
                Me.Label2.Text = objWord.Theme 'Assign the retreived theme value to the label for temporary storage
                listTheme.Text = objWord.Theme 'Setting the selected value of the dropdown list to be the same the retrieved theme value
                strVideoURL = objWord.Video 'Assign the retreived video filename value to variable
                strVideoPath = "http://www.babyslang.net/videoscap/" & strVideoURL 'Assign the URL of the video file to variable
                startVideo = True 'Enable auto video streaming
            End If
        End If
    End Sub

    Private Sub GridView1_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles GridView1.RowCommand
        If e.CommandName = "Select" Then
            Dim strKey As String = e.CommandArgument  'Getting Pk Value from argument
            Response.Redirect("ViewLearnIt.aspx?id=" + strKey) 'redirecting to ViewLearnIt.aspx with the selected WordID value
        End If
    End Sub
    
    Protected Sub btnPlay_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Database Variables
        Dim sqlconn As SqlConnection
        Dim sqlcmd As SqlCommand
        Dim drWordID As SqlDataReader
        
        'String Variables
        Dim strKey As String
        Dim tmpStatement As String

        'Connect to Database
        sqlconn = New SqlConnection("Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200")
        sqlconn.Open()

        'Setting the SQL statement to retrieve the WordID
        tmpStatement = "SELECT WordID FROM tbEngWords WHERE Word='" & DropDownList1.SelectedValue & "'"

        sqlcmd = New SqlCommand(tmpStatement, sqlconn) 'Create SQL Command object
        drWordID = sqlcmd.ExecuteReader 'Create SQL DataReader object
        drWordID.Read() 'Read the first row of the retreived data

        strKey = drWordID(0) 'Assign the retrieved data to variable
        drWordID.Close() 'Close SQL DataReader object
        sqlconn.Close() 'Close DB Connection

        'Session("learnSrcCtrl") = "grid"
        Response.Redirect("ViewLearnIt.aspx?id=" + strKey) 'redirecting to ViewLearnIt.aspx with the selected WordID value
    End Sub

''''''''''''''''''''''''''''''''''''''''Class Objects''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    'Object DBWord to be created at runtime to have a temporary storage of the required values 
    Public Class DBWord
        'Database Variables
        Dim objCmd As New SqlCommand
        Dim objCn As New SqlConnection
         
        'String Variables
        Dim strSQL As String
        Const CONNSTRING As String = "Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"

        Sub New() 'Procedure to create object instance
            objCn = New SqlConnection
            objCmd = New SqlCommand
            objCmd.Connection = objCn
            objCn.ConnectionString = CONNSTRING
        End Sub

        'Procedure to retrieve all records in the database and return the Array List
        Public Function getRecords() As ArrayList
            Dim objAdapter As New SqlDataAdapter
            Dim objDs As New DataSet
            Dim objDataRow As DataRow
            Dim objArrayList As New ArrayList

            strSQL = "Select * from tbEngWords;"

            objCmd.CommandText = strSQL
            objAdapter.SelectCommand = objCmd
            objCn.Open()
            objAdapter.Fill(objDs, "tblData")
            objCn.Close()
            For Each objDataRow In objDs.Tables("tblData").Rows 'Assign data records to Array List
                Dim objWord As New Word
                objWord.WordId = objDataRow.Item("WordID")
                objWord.WordName = objDataRow.Item("Word")
                objArrayList.Add(objWord)
            Next
            Return objArrayList
        End Function

        'Procedure to retrieve column Word and WordID all records in the database and return the DataSet Object
        Public Function displayAll() As DataSet
            Dim objAdapter As New SqlDataAdapter
            Dim objDs As New DataSet
            Dim objArrayList As New ArrayList
            Dim strSQL As String

            'Setting the SQL statement to retrieve the WordID and Word
            strSQL = "Select Word, WordID from tbEngWords;"
            objCn.Open()

            objCmd.CommandText = strSQL
            objAdapter.SelectCommand = objCmd
            objAdapter.Fill(objDs, "tblWordDisplayAll")
            objCn.Close()

            Return objDs
        End Function

        'Procedure to retrieve WordID, Word, Theme and Video from a record in the database, assign the values to a Word Object and return the Word Object
        Public Function RetrieveOneWord(ByVal pstrWordID As String) As Word

            Dim objAdapter As New SqlDataAdapter
            Dim objDs As New DataSet
            Dim objDataRow As DataRow
            Dim objArrayList As New ArrayList
            
            'Setting the SQL statement to retrieve a record with the specified WordID
            strSQL = "SELECT * FROM tbEngWords WHERE WordID = '" & pstrWordID & "'"
            objCn.Open() 'Open a connection to the database

            objCmd.CommandText = strSQL 'Set the SQL Command with variable
            objAdapter.SelectCommand = objCmd 'Set the SQL Command Object in the SQL Adapter object
            
            objAdapter.Fill(objDs, "tbEngWords") 'Fill the SQL Adapter Object with records
            objDataRow = objDs.Tables("tbEngWords").Rows(0) 'Retrieve the first row from the records
            
            Dim objWord As New Word
            
            'Assign the values from the first record to the Word object
            objWord.WordId = objDataRow.Item("WordID")
            objWord.WordName = objDataRow.Item("Word")
            objWord.Theme = objDataRow.Item("Theme")
            objWord.Video = objDataRow.Item("Video")

            objCn.Close() 'Close the DB Connection
            Return objWord
        End Function

        'Procedure to retrieve WordID and Theme from a record in the database, assign the values to a Word Object and return the Word Object
        Public Function RetrieveTheme(ByVal pstrWordID As String) As Word

            Dim objAdapter As New SqlDataAdapter
            Dim objDs As New DataSet
            Dim objDataRow As DataRow
            Dim objArrayList As New ArrayList

            'Setting the SQL statement to retrieve a record with the specified WordID
            strSQL = "SELECT Theme FROM tbEngWords WHERE WordID = '" & pstrWordID & "'"
            objCn.Open() 'Open a connection to the database

            objCmd.CommandText = strSQL 'Set the SQL Command with variable
            objAdapter.SelectCommand = objCmd 'Set the SQL Command Object in the SQL Adapter object


            objAdapter.Fill(objDs, "tbEngWords") 'Fill the SQL Adapter Object with records
            objDataRow = objDs.Tables("tbEngWords").Rows(0) 'Retrieve the first row from the records
            
            Dim objWord As New Word

            'Assign the values from the first record to the Word object
            objWord.WordId = objDataRow.Item("WordID")
            objWord.WordName = objDataRow.Item("Theme")

            objCn.Close() 'Close the DB Connection
            Return objWord
        End Function
    End Class

    'Object Word to be created at runtime to have a temporary storage of the required values
    'Object DBWord instance is assigned to Word. Object Word will interact with the web page.
    Public Class Word
        Protected intWordId As String
        Protected strWordName As String
        Protected strTheme As String
        Protected strGrp As String
        Protected strPictures As String
        Protected strVideo As String

        Property WordId() As String
            Get
                Return intWordId
            End Get
            Set(ByVal Value As String)
                intWordId = Value
            End Set
        End Property
        Property WordName() As String
            Get
                Return strWordName
            End Get
            Set(ByVal Value As String)
                strWordName = Value
            End Set
        End Property

        Property Theme() As String
            Get
                Return strTheme
            End Get
            Set(ByVal Value As String)
                strTheme = Value
            End Set
        End Property
        Property Grp() As String
            Get
                Return strGrp
            End Get
            Set(ByVal Value As String)
                strGrp = Value
            End Set
        End Property

        Property Pictures() As String
            Get
                Return strPictures
            End Get
            Set(ByVal Value As String)
                strPictures = Value
            End Set
        End Property

        Property Video() As String
            Get
                Return strVideo
            End Get
            Set(ByVal Value As String)
                strVideo = Value
            End Set
        End Property
    End Class

    ''''''''''''''''''''''''''''''''''''''''''''' End of Script ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''    
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
    <div id="subheader"><h2>Learn SEE</h2></div>
    <!-- End Sub Header -->

    <!-- Begin Navigation -->
    <div id="navigation">
        <ul id="Menu">
            <li><a href="http://www.babyslang.net/aboutus.aspx"><span>About Us</span></a></li>
            <li><a href="http://www.babyslang.net/Register.aspx"><span>Register</span></a></li>
            <li><a href="http://www.babyslang.net/Login.aspx"><span>Log In</span></a></li>
            <li><a href="http://www.babyslang.net/quiz.aspx"><span>Fun Quiz</span></a></li>
            <li><a href="http://www.babyslang.net/translateMain.aspx"><span>Translate to SEE</span></a></li>
            <li><a href="http://www.babyslang.net/home.aspx"><span>Home</span></a></li>
        </ul>
    </div>
    <!-- End Navigation -->

    <!-- Begin Sub Header 3 -->
    <div id="subheader3">
        <h2>Selected Theme is "<%= UCase(Label2.Text)%>". Current Word Shown is "<%=UCase(Label1.Text) %>" </h2>
    </div>
    <!-- End Sub Header -->
   
    <!-- Begin Quarter Column Left for Learning Interface -->
    <div id="quartercolumnleft_learn">      
        <asp:Label ID="Label1" runat="server" Text="Label" Visible="false"></asp:Label>
        <asp:Label ID="Label2" runat="server" ForeColor="Black" Text="Label" Visible="false"></asp:Label>
        <h2>Please select another theme:</h2><br />
        <asp:DropDownList ID="listTheme" runat="server" DataSourceID="SqlDataSource1" 
                            DataTextField="Theme" DataValueField="Theme" AutoPostBack="True" 
                            Font-Size="Large" Width="100%">
        </asp:DropDownList>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                                ConnectionString="Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"
                                SelectCommand="SELECT DISTINCT [Theme] FROM [tbEngWords]">
        </asp:SqlDataSource><br /><br />
        <h2>Please select another word:</h2><br />
        <asp:DropDownList ID="DropDownList1" runat="server" 
                        DataSourceID="SqlDataSource2" DataTextField="Word" DataValueField="Word" 
                        style="margin-bottom: 0px" AutoPostBack="True" Font-Size="Large" Width="100%">
        </asp:DropDownList>
        <asp:SqlDataSource ID="SqlDataSource2" runat="server" 
                        ConnectionString="Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"
                        SelectCommand="SELECT [Word] FROM [tbEngWords] WHERE ([Theme] = @Theme)">
            <SelectParameters>
                <asp:ControlParameter ControlID="listTheme" Name="Theme" 
                    PropertyName="SelectedValue" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource><br /><br />
        <asp:Button ID="btnPlay" runat="server" Text="Play Video" Font-Size="x-Large" OnClick="btnPlay_Click" Width="100%"/>
    </div>
    <!-- End Quarter Column Left for Learning Interface -->
              
    <!-- Begin Right Column Half-->
    <div id="rightcolumn_half">      
        <asp:Table  ID="table1" runat="server" HorizontalAlign="Center" height="290px" width= "425px">
            <asp:TableRow ID="tablerow1" runat="server">
                <asp:TableCell id="tablecell1" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                    <!-- Media Player Object -->
                    <object id="Video" classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6" 
                            type="application/x-oleobject" height="290px" width="425px" align="middle"
                            codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" >
                
                        <param name="URL" value="<%=strVideoPath %>" />
                        <param name="enabled" value="True" />
                        <param name="AutoStart" value="<%=startVideo %>" />
                        <param name="PlayCount" value="1" />
                        <param name="Volume" value="50" />
                        <param name="balance" value="0" />
                        <param name="Rate" value="1.0" />
                        <param name="Mute" value="False" />
                        <param name="fullScreen" value="False" />
                        <param name="uiMode" value="full"/>

                        <embed type="application/x-mplayer2" src="<%=strVideoPath %>" height="290px" width="425px" align="middle" name="MediaPlayer"></embed>
                    </object>
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>
    </div>
    <!-- End Right Column Half-->

    <!-- Begin Quarter Column Right for Learning Interface -->
    <div id="quartercolumnright_learn">
        <h4>Related Videos:</h4><br />
        <asp:GridView ID="GridView1" runat="server" AllowPaging="True" 
                        AllowSorting="True" AutoGenerateColumns="False" 
                        DataSourceID="SqlDataSource3" DataKeyNames="WordID" Width="100%" Height="110px" PageSize="3" BackColor="White" Font-Size="Small" GridLines="None" 
                        BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" ShowFooter="True" ForeColor="Black">
            <AlternatingRowStyle BackColor="#CCFF99" />
            <Columns>
                <asp:BoundField DataField="Word" HeaderText="Word" SortExpression="Word">
                    <HeaderStyle Font-Underline="False" ForeColor="Black" />
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                </asp:BoundField>
                <asp:TemplateField HeaderText="Click to Select Video">
                    <ItemTemplate>
                        <asp:ImageButton ID="lbtnSelect" CommandName="Select" CommandArgument='<%#Eval(”WordID”) %>' runat="server" ImageUrl="~/pictures/video2.jpg" />
                    </ItemTEmplate>
                    <HeaderStyle Font-Underline="True" />
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                </asp:TemplateField>
            </Columns>
            <FooterStyle BackColor="#CCFF99" />
            <HeaderStyle Height="30px" BackColor="#CCFF99" />
        </asp:GridView>
        <asp:SqlDataSource ID="SqlDataSource3" runat="server" 
                        ConnectionString="Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"           
                        SelectCommand="SELECT [Word], [WordID] FROM [tbEngWords] WHERE (([Theme] = @Theme) AND ([Word] &lt;&gt; @Word))">
            <SelectParameters>
                <asp:ControlParameter ControlID="Label2" Name="Theme" PropertyName="Text" Type="String" />
                <asp:ControlParameter ControlID="Label1" Name="Word" PropertyName="Text"  Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
    </div>
    <!-- End Quarter Column Right for Learning Interface -->

    <!-- Begin Footer -->
    <div id="footer"><h6 align="right">Copyright BabySlang 2010</h6></div>
    <!-- End Footer -->

    </div>  
    <!-- End Wrapper -->
    </form>
</body>
</html>
