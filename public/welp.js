$(function () {
    var input = $('input[type=text]').change(function () {
        $('img').attr('src', '/images/' + (input[0].value || ' ') + '/' + (input[1].value || ' '));
    });
});
