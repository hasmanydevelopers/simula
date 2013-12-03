 /**
 *Place all the behaviors and hooks related to the matching controller here.
 * All this logic will automatically be available in application.js.
 *You can use CoffeeScript in this file: http://coffeescript.org/
 */

$(document).ready(function() {
    $('.container').on('click','.button-to-add', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        var alerts = $('.alert.alert-success');
        alerts.remove();
        $('.jumbotron').remove();
        var url = $(this).attr('ajax_path');
        $.ajax(url, {
            success: function(response) {
            $('#first-part-sh').html(response).slideDown();
            },
            error: function(request, errorType, errorMessage) {
            alert('Error: ' + errorType + ' with message: ' + errorMessage);
            }
        });
    });

    $('.container').on('click', '#btn-to-submit-form-to-add', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        var container = $('#first-part-sh');
        var form = container.find('form');

        function getChosenSupervisorName() {
            chosenSupervisor = form.find('#therapy_session_supervisor_id');
            var chosenSupervisorId = +chosenSupervisor.val();
            var chosenSupervisorName = '';
            $.each(chosenSupervisor.find('option'), function() {
                if (+$(this).attr('value') === chosenSupervisorId) {
                     chosenSupervisorName = $(this).text();
                }
            });
            return chosenSupervisorName;
        }

        function editPendingSessionsNumber(supervisorName) {
            var allSupervisors = $('.table').find('.name-value');
            $.each(allSupervisors, function() {
                if ($(this).text() === supervisorName) {
                    var row = $(this).closest('tr');
                    var pendingColumn = row.find('a.pending');
                    pendingColumn.text(+pendingColumn.text() + 1);
                }
            });
        }

        var alerts = $('.alert.alert-danger');
        alerts.remove();
        var url = form.attr('action');
        var method = form.attr('method');
        $.ajax(url, {
            type: method,
            data: form.serialize(),
            success: function(response) {
                if (response.indexOf('alert-danger') == -1) {
                    editPendingSessionsNumber(getChosenSupervisorName());
                    var parent = container.closest('.container');
                    container.remove();
                    parent.prepend(response).slideDown();
                } else {
                    container.before(response).slideDown();
                }
            },
            error: function(request, errorType, errorMessage) {
            alert('Error: ' + errorType + ' with message: ' + errorMessage);
            }
        });
    });
});
