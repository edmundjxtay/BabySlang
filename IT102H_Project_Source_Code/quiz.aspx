<%@ Page Language="vb"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" language="javascript">

    window.history.forward(1);

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BabySlang.net - Signing Exact English (SEE) Educational Resource Website</title>
    <link rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
</head>
<body>
    <form id="form1" runat="server">
    
    <!-- Begin Wrapper -->
    <div id="wrapper">

    <!-- Begin Sub Header 2 -->
    <div id="subheader2"></div>
    <!-- End Sub Header 2 -->
   
    <!-- Begin Sub Header -->
    <div id="subheader"><h2>Fun Quiz</h2></div>
    <!-- End Sub Header -->
      
    <!-- Begin Navigation -->
    <div id="navigation">
        <ul id="Menu">
            <li><a href="http://www.babyslang.net/aboutus.aspx"><span>About Us</span></a></li>
            <li><a href="http://www.babyslang.net/Register.aspx"><span>Register</span></a></li>
            <li><a href="http://www.babyslang.net/Login.aspx"><span>Log In</span></a></li>
            <li><a href="http://www.babyslang.net/learnithome.aspx"><span>Learn SEE</span></a></li>
            <li><a href="http://www.babyslang.net/translateMain.aspx"><span>Translate to SEE</span></a></li>
            <li><a href="http://www.babyslang.net/home.aspx"><span>Home</span></a></li>
        </ul>
    </div>
    <!-- End Navigation -->
  
    <!-- Begin Sub Header -->
     <div id="subheader3"><h2>Please Click an Icon to Choose a Quiz Theme</h2></div>
    <!-- End Sub Header -->

    <!-- Begin Quarter Column 1 -->
    <div id="quartercolumn1">
    <h3>Simple SEE</h3><br />
      <asp:ImageMap ID="Image2"  CssClass="image2" runat="server" ImageUrl="~/pictures/simplesee.jpg" 
          ImageAlign="Middle" HotSpotMode="Navigate" 
          BorderColor="#333333" BorderStyle="Solid" 
          BorderWidth="1px" >
        <asp:RectangleHotSpot Bottom="280" Right="185" NavigateUrl="~/quizqn.aspx?userInput=other" />
      </asp:ImageMap> 
    </div>
    <!-- End Quater Column 1 -->
  
    <!-- Begin Quater Column 2 -->
    <div id="quartercolumn2">
        <h3>Family Members</h3><br />
        <asp:ImageMap ID="Image4"  CssClass="image2" runat="server" ImageUrl="~/pictures/family.jpg" 
          ImageAlign="Middle" HotSpotMode="Navigate" BorderColor="#333333" BorderStyle="Solid" 
          BorderWidth="1px" >
            <asp:RectangleHotSpot Bottom="280" Right="185" NavigateUrl="~/quizqn.aspx?userInput=family" />
        </asp:ImageMap> 
    </div>  
  
    <!-- End Quater Column 2 -->
  
    <!-- Begin Quater Column 3 -->
    <div id="quartercolumn3">
    <h3>Calender</h3><br />
        <asp:ImageMap ID="Image3" CssClass="image2" runat="server" ImageUrl="~/pictures/calendar.jpg" 
         ImageAlign="Middle" HotSpotMode="Navigate" BorderColor="#333333" BorderStyle="Solid" 
          BorderWidth="1px" >
                  <asp:RectangleHotSpot Bottom="280" Right="185" NavigateUrl="~/quizqn.aspx?userInput=month" />
        </asp:ImageMap>
    </div>
    <!-- End Quater Column 3 -->

    <!-- Begin Quater Column 4 -->
    <div id="quartercolumn4">
        <h3>At the Zoo</h3><br />
        <asp:ImageMap ID="Image1" CssClass="image2" runat="server" ImageUrl="~/pictures/zoo.jpg" 
          ImageAlign="Middle" HotSpotMode="Navigate" BorderColor="#333333" BorderStyle="Solid" 
          BorderWidth="1px" >
        <asp:RectangleHotSpot Bottom="280" Right="185" NavigateUrl="~/quizqn.aspx?userInput=zoo" />
        </asp:ImageMap>   
    </div>

    <!-- Begin Footer -->
    <div id="footer"><h6>Copyright BabySlang 2010</h6></div>
    <!-- End Footer -->

    </div>
    <!-- End Wrapper -->
    </form>
</body>
</html>
