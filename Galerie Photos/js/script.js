$(document).ready(function() {

    $("a[rel='galerie']").click(function(event) {
        event.preventDefault();
        $(".lightbox").html("<img src='" + $(this).attr("href") + "'>");
        $(".lightbox").append($("<a class='fleche'><button onclick='precedent()' class='gauche'> < </button></a>"));
        $(".lightbox").append($("<a class='fleche'><button onclick='suivant()'   class='droite'> > </button></a>"));
        $(".voile").fadeIn();
        $(".lightbox").fadeIn();
    })

    $(".voile").click(function() {
        $(".lightbox").fadeOut();
        $(".voile").fadeOut();
    })

});

var liste = ["img/1max.jpg", "img/2max.jpg", "img/3max.jpg", "img/4max.jpg", "img/5max.jpg"];
var i = 0;

function suivant() {
    if(i == 4){i = -1;}
    i += 1;
    $(".lightbox").html("<img src='" + liste[i] + "'>");
    $(".lightbox").append($("<a class='fleche'><button onclick='precedent()' class='gauche'> < </button></a>"));
    $(".lightbox").append($("<a class='fleche'><button onclick='suivant()'   class='droite'> > </button></a>"));
}

function precedent() {
    if(i == 0){i = 5;}
    i -= 1;
    $(".lightbox").html("<img src='" + liste[i] + "'>");
    $(".lightbox").append($("<a class='fleche'><button onclick='precedent()' class='gauche'> < </button></a>"));
    $(".lightbox").append($("<a class='fleche'><button onclick='suivant()'   class='droite'> > </button></a>"));
}