$(document).ready(function () {
    $('#room_open').on('change', function () { $(this).parents('form').submit(); });
    $('#room_name').on('focus', function () { $('#edit_room_submit').css({visibility: 'visible'}); });
});
