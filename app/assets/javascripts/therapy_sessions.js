/**
* Place all the behaviors and hooks related to the matching controller here.
* All this logic will automatically be available in application.js.
*/

$(document).ready(function() {
    $('ul').on('click', '.confirm-btn, .reject-btn', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        var pressedBtn = $(this);
        var url = pressedBtn.attr('href');

        var editBtnsToChangeState = function(row, new_state) {
            console.log('in makeAndInsertBtns');
            console.log(row);
            console.log(new_state);
            var confirmBtn = $('<a class="confirm-btn btn btn-default btn-lg"><span class="glyphicon glyphicon-ok"></span></a>');
            var rejectBtn = $('<a class="reject-btn btn btn-default btn-lg"><span class="glyphicon glyphicon-remove"></span></a>');
            if (new_state === 'confirmed') {
                confirmBtn.addClass('active');
                rejectBtn.addClass('no-active');
                rejectBtn.attr('href', url);
            } else {
                rejectBtn.addClass('active');
                confirmBtn.addClass('no-active');
                confirmBtn.attr('href', url);
            }
            var btnContainer = row.find('.edit-btn .btn-group');
            btnContainer.find('a').remove();
            btnContainer.html(confirmBtn);
            btnContainer.append(rejectBtn);
        };

        var editCounterBtnQuantity = function(btnScope, btnSelector, quantity) {
            var counterBtn = btnScope.closest('nav').find(btnSelector);
            counterBtn.text(parseInt(counterBtn.text(), 10) + quantity);
        };

        var createDateSection = function(new_state, event_date) {
            return $('<nav class="navbar navbar-default" role="navigation">' +
                        '<div class="navbar-header">' +
                            '<button type="button" class="' + new_state + ' inner-btn sessions-count-btn navbar-toggle btn-lg" data-toggle="collapse" data-target="#' + new_state + event_date +'">1</button>' +
                            '<a id="date-detail" class="navbar-brand">' + event_date + '</a>' +
                        '</div>' +
                        '<ul class="sessions-by-date collapse navbar-collapse nav navbar-nav" id="' + new_state + event_date + '">' +
                            '<table><tbody></tbody></table>' +
                        '</ul>' +
                    '</nav>');
        };

        var editNewStateSection = function(new_state, event_date) {
            var row = pressedBtn.closest('tr');
            row.detach();
            var ulOfNewState = $('#'+new_state);
            var ulOfNewStateDate = $('#'+new_state+event_date);
            var sessionsInNewStateDate = ulOfNewStateDate.find('tr');
            if (sessionsInNewStateDate.length !== 0) {
                editCounterBtnQuantity(ulOfNewStateDate, '.inner-btn', 1);
                editCounterBtnQuantity(ulOfNewState, '.outer-btn', 1);
                ulOfNewStateDate.find('tbody').prepend(row);
            } else {
                var dateSection = createDateSection(new_state,event_date);
                dateSection.find('tbody').html(row);
                var sessionsInNewState = ulOfNewState.find('nav');
                var indexOfSessionsInNewState = sessionsInNewState.length;
                if (indexOfSessionsInNewState === 0) {
                    ulOfNewState.find('li').remove();
                    ulOfNewState.html(dateSection);
                } else {
                    $.each(sessionsInNewState, function() {
                        if (new Date($(this).find('#date-detail').text()) < new Date(event_date)) {
                            $(this).before(dateSection);
                            return false;
                        } else if (indexOfSessionsInNewState === 1) {
                            $(this).after(dateSection);
                        }
                        indexOfSessionsInNewState = indexOfSessionsInNewState - 1;
                    });
                }
                editCounterBtnQuantity(ulOfNewState, '.outer-btn', 1);
            }
            editBtnsToChangeState(row, new_state);
        };

        var editOldStateSection = function(old_state, event_date) {
            var ulOfOldState = $('#'+old_state);
            var ulOfOldStateDate = $('#'+old_state+event_date);
            var sessionsInOldStateDate = ulOfOldStateDate.find('tr');
            if (sessionsInOldStateDate.length > 0) {
                editCounterBtnQuantity(ulOfOldStateDate, '.inner-btn', -1);
                editCounterBtnQuantity(ulOfOldState, '.outer-btn', -1);
            } else {
                var sessionsInOldState = ulOfOldState.find('nav');
                if (sessionsInOldState.length === 1) {
                    var noSessionsMsg = old_state === 'pending' ? 'You have no sessions pending for confirmation.' : 'You have no ' + old_state + ' sessions.';
                    var noSessionsMsgContainer = $('<li>' +
                                '<a id="sessions-index-msg" class="navbar-brand">' +
                                    noSessionsMsg +
                                '</a>' +
                            '</li>');
                    ulOfOldState.html(noSessionsMsgContainer);
                }
                editCounterBtnQuantity(ulOfOldState, '.outer-btn', -1);
                ulOfOldStateDate.closest('nav').remove();
            }
        };

        $.ajax(url, {
            dataType: 'json',
            contentType: 'application/json',
            success: function(respond) {
                var new_state = respond.new_state;
                var old_state = respond.old_state;
                var event_date = respond.event_date;
                editNewStateSection(new_state, event_date);
                editOldStateSection(old_state, event_date);
            },
            error: function(request, errorType, errorMessage) {
                alert('Error: ' + errorType + ' with message: ' + errorMessage);
            }
        });
    });
});
