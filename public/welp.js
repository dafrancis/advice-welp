$(function () {
    var input = $('input[type=text]').keydown(function () {
        $('img').attr('src', '/images/' + (input[0].value || ' ') + '/' + (input[1].value || ' '));
    });
});
