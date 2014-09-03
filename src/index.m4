<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en-US">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Damion Wilson's Blog</title>

    <script src="d3.min.js" charset="utf-8">
    </script>

    <script>
        if (typeof d3 == 'undefined') {
            document.write(
                unescape(
                    '%3Cscript src="http://d3js.org/d3.v3.min.js"%3E%3C/script%3E'
                )
            )
        }
    </script>

    <link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300' rel='stylesheet' type='text/css'>
    <link href='http://fonts.googleapis.com/css?family=PT+Serif:700' rel='stylesheet' type='text/css'>

    <style type="text/css" rel="stylesheet">
        body {
            font-family: 'Open Sans Condensed', sans-serif;
        }

        .sidebar {
            position: fixed;
            display: table;
            left: 0px;
            top: 0px;
            height: 100%;
            padding: 12px;
            margin: 1px;
            background: #8b9b77;
            box-shadow: 6px 6px 5px #888888;
            border-radius: 1px;
            color: white;
            width: 100px;
        }

        .sidebar > header {
            color: white;
            font-weight: bold;
            font-size: 1.2em;
        }

        .sidebar > ul {
            padding: 0px;
            margin: 0px;
        }

        .nobullets {
            text-decoration: none;
            display: block;
            list-style-type: none;
        }

        .nobullets > li {
            cursor: pointer;
        }

        .nobullets > li:hover {
            color: yellow;
        }

        .nobullets > li > a {
            text-decoration: none;
        }

        .nobullets > li > a:active,
        .nobullets > li > a:hover {
            color: yellow;
        }

        .main {
            position: relative;
            margin-left: 128px;
            margin-right: 10px;
        }

        .main > div:nth-of-type(1) {
            position: fixed;
            top: 0;
            left: 130px;
            right: 0px;
            padding: 20px;
            margin-top: 2px;
            margin-right: 20px;
            margin-bottom: 50px;
            background: #8b9b77;
            background-image: url('banner.jpg');
            border-bottom: medium thick #202020;
            box-shadow: 6px 6px 5px #888888;
        }

        .main > div:nth-of-type(2) {
            padding-top: 120px;
            margin-left: 10px;
        }

        .main > div:nth-of-type(2) > * {
            display: none;
        }

        /*----------------------------------------*/
        .post-meta {
            display: inline-block;
            font-size: 1.4rem;
            line-height: 1;
            color: #9EABB3;
        }

        .post-meta a{
            color: #9EABB3;
            text-decoration: none;
        }

        .post-meta a:hover{
            text-decoration: underline;
        }

        /*----------------------------------------*/
        .blog-title {
            margin:0;
            font-size:2.2rem;
            letter-spacing:1px;
            font-weight:bold;
            font-family: 'PT Serif', serif;
            text-transform:uppercase;
            color: #f0f060;
        }

        .blog-title a{
            color: inherit;
            text-decoration:none;
        }

        .blog-description{
            margin:0;
            font-size:1.5rem;
            line-height:1em;
            font-weight:normal;
            color: #f0f060;
            letter-spacing:0;
        }

        .linkformat {
            line-height: 20px;
            margin-left: 10px;
            text-align: left;
            padding-top: 10px;
        }

        .linkformat > li {
            font-size: 1.4em;
            margin: 12px;
        }

        .linkformat > li > a {
            text-decoration: none;
        }

        .linkformat > li > a:active,
        .linkformat > li > a:hover {
            text-decoration: underline;
            color: yellow;
        }

        .jumpto {
            position: absolute;
            margin-top: -120px;
        }

        #archive {
            text-indent: 10px;
            padding-top: 5px;
        }

        #archive > li {
        }

        pre {
            background: #efefff;
            /* opacity: 0.8; */
            border: 0px solid black;
            width: 80%;
            margin-left: 20px;
            padding-left: 10px;
        }
    </style>

    <style media="only screen and (max-device-width: 768px)" type="text/css">
        .sidebar {
            position: inherit;
            width: inherit;
            margin: 0;
            padding: 25px;
        }

        .content {
            margin: 0;
            padding: 5px 25px;
            width: inherit;
        }
    </style>

    <script>
        function raise_section(section_name) {
            var section_tag = '#' + section_name;
            var root = d3.select(".main").select("div:nth-of-type(2)");
            root.selectAll("section").style("display", "none");
            root.selectAll(section_tag).style("display", "inline");
        }

        function select_section(obj) {
            raise_section(obj.innerHTML.toLowerCase());
        }

        function init() {
            var section_names = d3
                .select(".main")
                .select("div:nth-of-type(2)")
                .selectAll("section")[0]
                .map(
                    function(_selection) {
                        return _selection.id;
                    }
                )
            ;

            d3
                .select("#choices")
                .selectAll("li")
                .data(section_names)
                .enter()
                    .append("li")
                    .attr("onclick", function(d) {return "raise_section('" + d + "');";})
                    .text(function(d) { return d;})
            ;

            var blog_names = d3.selectAll(".jumpto")[0].map(
                function(_selection) {
                    return _selection.name;
                }
            );

            d3
                .select("#archive")
                .selectAll("li")
                .data(blog_names)
                .enter()
                    .append("li")
                    .append("a")
                    .attr("href", function(d) {return "#" + d;})
                    .attr("onclick", "raise_section('Blog');")
                    .text(function(d) { return d;})
            ;

            raise_section('Blog');
        }
    </script>
</head>
<body onload="init();">
<div class="sidebar">
    <header>
        Damion Wilson's Blog
    </header>
    <hr>
    <div class="buttonbar">
<a href="https://github.com/damionw">
    <svg width="20px" height="20px" viewBox="0 0 60 60" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sketch="http://www.bohemiancoding.com/sketch/ns">
        <path d="M0.336871032,30 C0.336871032,13.4314567 13.5672313,0 29.8877097,0 C46.208188,0 59.4385483,13.4314567 59.4385483,30 C59.4385483,46.5685433 46.208188,60 29.8877097,60 C13.5672313,60 0.336871032,46.5685433 0.336871032,30 Z M0.336871032,30" id="Github" fill="#333333" sketch:type="MSShapeGroup"></path>
        <path d="M18.2184245,31.9355566 C19.6068506,34.4507902 22.2845295,36.0156764 26.8007287,36.4485173 C26.1561023,36.9365335 25.3817877,37.8630984 25.2749857,38.9342607 C24.4644348,39.4574749 22.8347506,39.62966 21.5674303,39.2310659 C19.7918469,38.6717023 19.1119377,35.1642642 16.4533306,35.6636959 C15.8773626,35.772144 15.9917933,36.1507609 16.489567,36.4722998 C17.3001179,36.9955141 18.0629894,37.6500075 18.6513541,39.04366 C19.1033554,40.113871 20.0531304,42.0259813 23.0569369,42.0259813 C24.2489236,42.0259813 25.0842679,41.8832865 25.0842679,41.8832865 C25.0842679,41.8832865 25.107154,44.6144649 25.107154,45.6761142 C25.107154,46.9004355 23.4507693,47.2457569 23.4507693,47.8346108 C23.4507693,48.067679 23.9990832,48.0895588 24.4396415,48.0895588 C25.3102685,48.0895588 27.1220883,47.3646693 27.1220883,46.0918317 C27.1220883,45.0806012 27.1382993,41.6806599 27.1382993,41.0860982 C27.1382993,39.785673 27.8372803,39.3737607 27.8372803,39.3737607 C27.8372803,39.3737607 27.924057,46.3153869 27.6704022,47.2457569 C27.3728823,48.3397504 26.8360115,48.1846887 26.8360115,48.6727049 C26.8360115,49.3985458 29.0168704,48.8505978 29.7396911,47.2571725 C30.2984945,46.0166791 30.0543756,39.2072834 30.0543756,39.2072834 L30.650369,39.1949165 C30.650369,39.1949165 30.6837446,42.3123222 30.6637192,43.7373675 C30.6427402,45.2128317 30.5426134,47.0792797 31.4208692,47.9592309 C31.9977907,48.5376205 33.868733,49.5526562 33.868733,48.62514 C33.868733,48.0857536 32.8436245,47.6424485 32.8436245,46.1831564 L32.8436245,39.4688905 C33.6618042,39.4688905 33.5387911,41.6768547 33.5387911,41.6768547 L33.5988673,45.7788544 C33.5988673,45.7788544 33.4186389,47.2733446 35.2190156,47.8992991 C35.8541061,48.1209517 37.2139245,48.1808835 37.277815,47.8089257 C37.3417055,47.4360167 35.6405021,46.8814096 35.6252446,45.7236791 C35.6157088,45.0178155 35.6567131,44.6059032 35.6567131,41.5379651 C35.6567131,38.470027 35.2438089,37.336079 33.8048426,36.4323453 C38.2457082,35.9766732 40.9939527,34.880682 42.3337458,31.9450695 C42.4383619,31.9484966 42.8791491,30.5737742 42.8219835,30.5742482 C43.1223642,29.4659853 43.2844744,28.1550957 43.3168964,26.6025764 C43.3092677,22.3930799 41.2895654,20.9042975 40.9014546,20.205093 C41.4736082,17.0182425 40.8060956,15.5675121 40.4961791,15.0699829 C39.3518719,14.6637784 36.5149435,16.1145088 34.9653608,17.1371548 C32.438349,16.3998984 27.0982486,16.4712458 25.0957109,17.3274146 C21.4005522,14.6875608 19.445694,15.0918628 19.445694,15.0918628 C19.445694,15.0918628 18.1821881,17.351197 19.1119377,20.6569598 C17.8961113,22.2028201 16.9902014,23.2968136 16.9902014,26.1963718 C16.9902014,27.8297516 17.1828264,29.2918976 17.6176632,30.5685404 C17.5643577,30.5684093 18.2008493,31.9359777 18.2184245,31.9355566 Z M18.2184245,31.9355566" id="Path" fill="#FFFFFF" sketch:type="MSShapeGroup"></path>
        <path d="M59.4385483,30 C59.4385483,46.5685433 46.208188,60 29.8877097,60 C23.8348308,60 18.2069954,58.1525134 13.5216148,54.9827754 L47.3818361,5.81941103 C54.6937341,11.2806503 59.4385483,20.0777973 59.4385483,30 Z M59.4385483,30" id="reflec" fill-opacity="0.08" fill="#000000" sketch:type="MSShapeGroup"></path>
    </svg>
</a>
<a href="mailto:damionw@gmail.com" subject="blog comment">
<svg width="20px" height="20px" viewBox="0 0 60 60" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sketch="http://www.bohemiancoding.com/sketch/ns">
    <path d="M0.224580688,30 C0.224580688,13.4314567 13.454941,0 29.7754193,0 C46.0958976,0 59.3262579,13.4314567 59.3262579,30 C59.3262579,46.5685433 46.0958976,60 29.7754193,60 C13.454941,60 0.224580688,46.5685433 0.224580688,30 Z M0.224580688,30" fill="#FFFFFF" sketch:type="MSShapeGroup"></path>
    <path d="M35.0384324,31.6384006 L47.2131148,40.5764264 L47.2131148,20 L35.0384324,31.6384006 Z M13.7704918,20 L13.7704918,40.5764264 L25.9449129,31.6371491 L13.7704918,20 Z M30.4918033,35.9844891 L27.5851037,33.2065217 L13.7704918,42 L47.2131148,42 L33.3981762,33.2065217 L30.4918033,35.9844891 Z M46.2098361,20 L14.7737705,20 L30.4918033,32.4549304 L46.2098361,20 Z M46.2098361,20" id="Shape" fill="#333333" sketch:type="MSShapeGroup"></path>
    <path d="M59.3262579,30 C59.3262579,46.5685433 46.0958976,60 29.7754193,60 C23.7225405,60 18.0947051,58.1525134 13.4093244,54.9827754 L47.2695458,5.81941103 C54.5814438,11.2806503 59.3262579,20.0777973 59.3262579,30 Z M59.3262579,30" id="reflec" fill-opacity="0.08" fill="#000000" sketch:type="MSShapeGroup"></path>
</svg>
</a>

<a href="http://www.linkedin.com/pub/damion-wilson/3/773/766">
<svg width="20px" height="20px" viewBox="0 0 60 60" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sketch="http://www.bohemiancoding.com/sketch/ns">
    <path d="M0.449161376,30 C0.449161376,13.4314567 13.6795217,0 30,0 C46.3204783,0 59.5508386,13.4314567 59.5508386,30 C59.5508386,46.5685433 46.3204783,60 30,60 C13.6795217,60 0.449161376,46.5685433 0.449161376,30 Z M0.449161376,30" fill="#007BB6" sketch:type="MSShapeGroup"></path>
    <path d="M22.4680392,23.7098144 L15.7808366,23.7098144 L15.7808366,44.1369537 L22.4680392,44.1369537 L22.4680392,23.7098144 Z M22.4680392,23.7098144" id="Path" fill="#FFFFFF" sketch:type="MSShapeGroup"></path>
    <path d="M22.9084753,17.3908761 C22.8650727,15.3880081 21.4562917,13.862504 19.1686418,13.862504 C16.8809918,13.862504 15.3854057,15.3880081 15.3854057,17.3908761 C15.3854057,19.3522579 16.836788,20.9216886 19.0818366,20.9216886 L19.1245714,20.9216886 C21.4562917,20.9216886 22.9084753,19.3522579 22.9084753,17.3908761 Z M22.9084753,17.3908761" id="Path" fill="#FFFFFF" sketch:type="MSShapeGroup"></path>
    <path d="M46.5846502,32.4246563 C46.5846502,26.1503226 43.2856534,23.2301456 38.8851658,23.2301456 C35.3347011,23.2301456 33.7450983,25.2128128 32.8575489,26.6036896 L32.8575489,23.7103567 L26.1695449,23.7103567 C26.2576856,25.6271338 26.1695449,44.137496 26.1695449,44.137496 L32.8575489,44.137496 L32.8575489,32.7292961 C32.8575489,32.1187963 32.9009514,31.5097877 33.0777669,31.0726898 C33.5610713,29.8530458 34.6614937,28.5902885 36.5089747,28.5902885 C38.9297703,28.5902885 39.8974476,30.4634101 39.8974476,33.2084226 L39.8974476,44.1369537 L46.5843832,44.1369537 L46.5846502,32.4246563 Z M46.5846502,32.4246563" id="Path" fill="#FFFFFF" sketch:type="MSShapeGroup"></path>
    <path d="M59.5508386,30 C59.5508386,46.5685433 46.3204783,60 30,60 C23.9471212,60 18.3192858,58.1525134 13.6339051,54.9827754 L47.4941264,5.81941103 C54.8060245,11.2806503 59.5508386,20.0777973 59.5508386,30 Z M59.5508386,30" id="reflec" fill-opacity="0.08" fill="#000000" sketch:type="MSShapeGroup"></path>
</svg>
</a>
    </div>
    <hr>
    <ul class="nobullets" id="choices">
    </ul>

    <hr>
    Archives
    <ul class="nobullets" id="archive">
    </ul>
</div>

<div class="main">
    <div>
        <h1 class="blog-title">
            <a href="http://damionw.github.io/">
                Geek on a Rock
            </a>
        </h1>

        <h2 class="blog-description">
            Programming in Bermuda ... and other stuff
        </h2>
    </div>

    <div>
        <section id="Links">
            LINK_CONTENTS
        </section>

        <section id="About">
            ABOUT_CONTENTS
        </section>

        <section id="Blog">
            BLOG_CONTENTS
        </section>
    </div>
</div>
</body>
</html>
