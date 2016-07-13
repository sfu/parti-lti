$(document).ready(function () {

    var links = $('.action-export a');
    var exportAllContainer = $('#container-export_all');

    links.each(function () {
        var container = $(this).parent();
        $(this).on('click', function (event) {
            var link = $(this);
            event.preventDefault();
            container.removeClass('action-successful action-failed').addClass('action-loading');
            $.get(this.href, function (data) {
                container.removeClass('action-loading');
                if (data.success) {
                    container.addClass('action-successful');
                    link.attr('title', 'Export successful');
                } else {
                    container.addClass('action-failed');
                    link.attr('title', 'Error: ' + (data.error ? data.error : 'Unknown'));
                }
            });
        });
    });

    // Create a way to easily batch export all grades. Exports are spread out in 500ms intervals.
    $('<button>Export all</button>').appendTo(exportAllContainer).on('click', function (event) {
        var interval = 250;
        var processingDelay = interval * links.length;
        var button = $(this);
        event.preventDefault();
        links.each(function (index, link) {
            window.setTimeout(function () { $(link).click(); }, interval * index);
        });
        button.prop('disabled', true).addClass('processing').text('Exporting...');
        // Future improvement opportunity: this would be even better if it is triggered by event completion.
        window.setTimeout(function () {
            $('<div>Grades exported</div>').addClass('status').insertAfter(button);
            button.remove();
        }, processingDelay);
    });

});
