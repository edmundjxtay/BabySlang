<%@ Page Language="vb" Debug="true" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>

<script runat="server" language="vbscript">
    Protected Sub wordGrid_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles wordGrid.RowCommand
        If e.CommandName = "Select" Then
            Dim strKey As String = e.CommandArgument  'Getting Pk Value from argument
            Response.Redirect("ViewLearnIt.aspx?id=" + strKey) 'redirecting to ViewLearnIt.aspx with the selected WordID value
        End If
    End Sub
    ''''''''''''''''''''''''''''''''''''''''''''' End of Script ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BabySlang.net - Signing Exact English (SEE) Educational Resource Website</title>
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
        <asp:Table id="Table2" runat="server" Width="100%" Height="100%">
            <asp:TableRow id="TableRow2" runat="server" Width="100%" Height="100%">
                <asp:TableCell id="TableCell2" runat="server" Width="35%"><h2>Please Select a Category:</h2></asp:TableCell>
                <asp:TableCell ID="TableCell3" runat="server" Width="65%">
                    <asp:DropDownList ID="DropDownList1" runat="server"  
                            DataSourceID="SqlDataSource1" DataTextField="Theme" DataValueField="Theme" 
                            AutoPostBack="True" Font-Size="X-Large">
                    </asp:DropDownList>
                    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                            ConnectionString="Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"
                            SelectCommand="SELECT DISTINCT [Theme] FROM [tbEngWords]">
                    </asp:SqlDataSource>
                </asp:TableCell>
                <asp:TableCell ID="TableCell4" runat="server" Width="50%">&nbsp;</asp:TableCell>
            </asp:TableRow>
        </asp:Table>
    </div>
    <!-- End Sub Header -->
   
    <!-- Begin Left Column Half -->
    <div id="leftcolumn_half">
        <asp:Table ID="table1" runat="server" HorizontalAlign="Center" height="290px" width= "425px">
            <asp:TableRow ID="tablerow1" runat="server">
                <asp:TableCell id="tablecell1" runat="server" VerticalAlign="Middle" height="290px" width= "425px">
                    <asp:GridView ID="wordGrid" runat="server" AllowPaging="True" AllowSorting="True" 
                                    AutoGenerateColumns="False" DataSourceID="SqlDataSource2" 
                                    style="text-align: center" ViewStateMode="Disabled" height="290px" width= "425px" 
                                    DataKeyNames="WordID" Font-Size="Large" 
                                    EnableModelValidation="True" Font-Underline="False" BackColor="White" 
                                    PageSize="3" BorderColor="Black" BorderStyle="Solid" BorderWidth="1px" 
                                    GridLines="None" ShowFooter="True" Font-Bold="True">
                        <AlternatingRowStyle BackColor="#CCFF99" />
                        <Columns>
                            <asp:BoundField DataField="Word" HeaderText="Word" SortExpression="Word">
                                <HeaderStyle ForeColor="Black" />
                                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" ForeColor="Black" Font-Bold="True" />
                            </asp:BoundField>
                                <asp:TemplateField HeaderText="Click to Select Video">
                                    <ItemTemplate>
                                        <asp:ImageButton ID="lbtnSelect" CommandName="Select" CommandArgument='<%#Eval(”WordID”) %>' runat="server" ImageUrl="~/pictures/video3.jpg" ImageAlign="Middle" />
                                    </ItemTEmplate>
                                        <HeaderStyle Font-Underline="True" />
                                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                </asp:TemplateField>
                        </Columns>
                        <FooterStyle BackColor="#CCFF99" />
                        <HeaderStyle Height="45px" BackColor="#CCFF99" />
                    </asp:GridView>
                    <asp:SqlDataSource ID="SqlDataSource2" runat="server" 
                        ConnectionString="Server=204.93.178.45;Database=edmundtay81_babyslangdb;UID=edmundtay81_public;Password=1234qwer;MultipleActiveResultSets=True;Max Pool Size=200;Connect Timeout=200"
                        SelectCommand="SELECT DISTINCT [Word], [WordID] FROM [tbEngWords] WHERE ([Theme] = @Theme)">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="DropDownList1" Name="Theme" 
                                PropertyName="SelectedValue" Type="String" />
                        </SelectParameters>
                        <SelectParameters> 
                        <asp:QueryStringParameter Name="WordID" DefaultValue="0" QueryStringField="WordID" Type="Int32" />                       
                        </SelectParameters>
                    </asp:SqlDataSource>   
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
                    <asp:Image ID="image1" runat="server" height="290px" width= "425px" Visible="true" ImageUrl="~/pictures/learn3.jpg" />
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
