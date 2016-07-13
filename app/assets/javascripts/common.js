(function ($) {

    function fixPageTitle() {
        // Ensure the page title does not overlap with the back link (on the left) and secondary link (on the right).
        // The calculation is based on the longest link, because title is center-aligned.
        var maxWidth = ($('body').width() / 2 - Math.max($('#top-back').width(), $('#top-secondary').width())) * 2;
        $('#top-title').css('max-width', maxWidth);
    }

    $(document).ready(function () {
        // Only fix page title if it is present
        if ($('#top-title').length > 0) {
            fixPageTitle();
            $(window).on('resize', fixPageTitle);
        }
    });

})(jQuery);
