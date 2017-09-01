$(function() {
  $(".checkbox input").click(function() {
    var checkbox = $(this);
    if (checkbox.data("hideable"))
      $("." + checkbox.data("class")).toggleClass("hide");
    else
      $("." + checkbox.data("class")).toggleClass(checkbox.data("toggle-class"));
  });
});