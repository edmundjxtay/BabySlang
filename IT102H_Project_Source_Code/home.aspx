<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BabySlang - Signing Exact English (SEE) Educational Resource Website</title>
    <meta name="abstract" content="BabySlang.net is a free online Signing Exact English (SEE) educational resource website to aid teaching the language to children between 3 to 5 years old." />
    <meta name="description" content="BabySlang.net is a free online Signing Exact English (SEE) educational resource website to aid teaching the language to children between 3 to 5 years old." />
    <meta name="keywords" content="signing exact english language, signed exact english, sign language, manually coded english, learn sign language, children sign language, learn see free, see, signs, videos, free, deaf, children, conversational phrases, fingerspell" />
    <meta name="copyright" content="2010 BabySlang.net" />
    <meta name="robots" content="index,follow" />
    <meta name="distribution" content="global" />
    <meta name="revisit-after" content="3 days" />
    <link rel="stylesheet" type="text/css" href="~/css/styles_home.css" />
</head>
<body>
    <form id="form1" runat="server">
       
    <!-- Begin Wrapper -->
    <div id="wrapper">
  
    <!-- Begin Header -->
    <div id="header">
      </div>
    <!-- End Header -->

    <div id="navigation">
        <ul id="Menu">
            <li><a href="http://www.babyslang.net/aboutus.aspx"><span>About Us</span></a></li>
            <li><a href="http://www.babyslang.net/Register.aspx"><span>Register</span></a></li>
            <li><a href="http://www.babyslang.net/Login.aspx"><span>Log In</span></a></li>
        </ul>
    </div>

    <!-- Begin Sub Header -->
    <div id="subheader"><h2>Please Click an Icon to Choose an Option</h2></div>
    <!-- End Sub Header -->

    <!-- Begin Left Column -->
    <div id="leftcolumn">
        <h3>Translate to SEE</h3><br />
        <asp:ImageMap  CssClass="image" ID="Image1" runat="server" 
          ImageUrl="~/pictures/translate2.jpg" ImageAlign="Middle" 
          BorderColor="#333333" HotSpotMode="Navigate" BorderStyle="Solid" 
          BorderWidth="1px" >
          <asp:RectangleHotSpot Bottom="180" HotSpotMode="Navigate" 
              NavigateUrl="~/translateMain.aspx" Right="262" />
        </asp:ImageMap>
    </div>
    <!-- End Left Column -->
  
    <!-- Begin Centre Column -->
    <div id="centrecolumn">
        <h3>Learn SEE</h3><br />
        <asp:ImageMap  CssClass="image" ID="ImageMap1" runat="server" 
          ImageUrl="~/pictures/learn.jpg" ImageAlign="Middle" 
          BorderColor="#333333" HotSpotMode="Navigate" BorderStyle="Solid" 
          BorderWidth="1px" >
          <asp:RectangleHotSpot Bottom="180" HotSpotMode="Navigate" 
              NavigateUrl="~/learnithome.aspx" Right="262" />
        </asp:ImageMap>
    </div>
    <!-- End Centre Column -->
  
    <!-- Begin Right Column -->
    <div id="rightcolumn">
        <h3>Fun Quiz</h3><br />
        <asp:ImageMap  CssClass="image" ID="ImageMap2" runat="server" 
          ImageUrl="~/pictures/quiz.jpg" ImageAlign="Middle" 
          BorderColor="#333333" HotSpotMode="Navigate" BorderStyle="Solid" 
          BorderWidth="1px" >
          <asp:RectangleHotSpot Bottom="180" HotSpotMode="Navigate" 
              NavigateUrl="~/quiz.aspx" Right="262" />
        </asp:ImageMap>
  
    </div>
    <!-- End Right Column -->
  
    <!-- Begin Footer -->
    <div id="footer"><h5 align="right">Copyright BabySlang 2010</h5></div>
    <!-- End Footer -->
    
    </div>
    <!-- End Wrapper -->
    </form>
</body>
</html>
