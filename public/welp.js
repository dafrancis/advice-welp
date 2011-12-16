$(function () {
    var input = $('input[type=text]').keypress(function () {
        $('img').attr('src', '/images/' + (input[0].value || ' ') + '/' + (input[1].value || ' '));
    });
});
