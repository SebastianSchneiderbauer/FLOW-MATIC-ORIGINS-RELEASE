% scenes/scene_5.pl - The final scene: The Pentagon pitch (dialogue tree)

:- dynamic(dialogue_state/2).
:- dynamic(current_scene/1).

:- discontiguous(print_question/2).
:- discontiguous(handle_answer/3).
:- discontiguous(scene_reset/0).

% --- Scene Reset Logic ---
scene_reset :-
	retractall(current_scene(_)),
	asserta(current_scene(scene_5)),  % ensure state routing stays correct
	write('You enter the meeting room. The committee looks at you expectantly.'), nl,
	write('It is time to present your vision for a new programming language.'), nl,
	write('choose an answer using \'answer(OPTION)\' (e.g., answer(a). )'), nl,
	retractall(dialogue_state(_, _)),
	asserta(dialogue_state(q0, 0)),
	print_question(q0, 0),
	true.

% --- Room Definitions ---
room(meeting_room, 'You are in the Pentagon meeting room. The committee awaits your pitch.', []).

room_intro_text(meeting_room, []).

print_intro_text(Room) :-
	room_intro_text(Room, Lines),
	forall(member(Line, Lines), (write(Line), nl)).

% --- Dialogue Commands ---
handle_scene5_command(look) :-
	dialogue_state(Q, S),
	print_question(Q, S).

handle_scene5_command(answer(Option)) :-
	dialogue_state(Q, S),
	handle_answer(Q, Option, S).

handle_scene5_command(help) :-
	forall(member(Line, [
		'Available commands:',
		'  look.             -- repeat the current question',
		'  answer(Option).   -- answer with a, b, or c (e.g., answer(a). )',
		'  help.             -- show this help',
		'  quit.             -- quit the game'
	]), (write(Line), nl)).

% --- Questions ---
print_question(q0, _) :-
	forall(member(Line, [
		'Committee: What is the main reason for your pitch of this new programming language?',
		'  a) It enables non-technical people to write programs.',
		'  b) It will make it easier to standardize business logic across organizations.',
		'  c) It removes the need for programmers entirely.'
	]), (write(Line), nl)).
print_question(q1a, _) :-
	forall(member(Line, [
		'Committee: High-level code is slower. Isn''t that a bug, not a feature?',
		'  a) Hardware is evolving rapidly; readability and maintainability are more important than raw speed.',
		'  b) Speed is irrelevant in business applications.'
	]), (write(Line), nl)).
print_question(q1b, _) :-
	forall(member(Line, [
		'Committee: Why would companies adopt this? They already have working systems.',
		'  a) We will force them to switch.',
		'  b) A shared standard will reduce integration problems and costs.'
	]), (write(Line), nl)).
print_question(q2a, _) :-
	forall(member(Line, [
		'Committee: Who would maintain these programs if non-technical people write them?',
		'  a) We will train staff to maintain and extend the programs.',
		'  b) There will be no need for maintenance.'
	]), (write(Line), nl)).
print_question(q2b, _) :-
	forall(member(Line, [
		'Committee: What if people refuse to give up their old systems?',
		'  a) We will shame them into adopting the new standard.',
		'  b) They will, if the industry as a whole demands it.'
	]), (write(Line), nl)).
print_question(end_good, _) :-
	forall(member(Line, [
		'The committee nods in agreement.',
        '"Mrs. Hopper, that sounds like an incredible idea. We will be happy to pursue and fund it!"',
        'You want to dance and jump around like a child opening their Christmas presents, but you stay calm.',
        'Further research into higher-level programming languages later leads to COBOL, changing the world of business programming forever.',
        ' ',
		'FLOW-MATIC ORIGINS:',
        'THE GOOD ENDING: IMMORTALISED...',
        'Created by HTL-LEONDING students ADRIAN PICHLER and SEBASTIAN SCHNEIDERBAUER.'
	]), (write(Line), nl)).

print_question(end_bad, _) :-
	forall(member(Line, [
		'The committee is not convinced.',
        '"Mrs. Hopper, I will have to ask you to leave. You have wasted our time. We will neither pursue nor fund this idea!"',
        'You slowly walk out of the meeting room.',
        'All your hard work, gone, instantly...',
        'You take one last look inside the room and see one man smiling villainously. He is planning something...',
        ' ',
        'A FEW DAYS LATER',
        ' ',
        'You pick up the newspaper, still depressed your idea wasnt accepted. As you read the headline, you spit out your tea.',
        'The man you saw smiling in the Pentagon stole your idea, repitched it, and got it accepted claiming full ownership!',
        'He will go down in history. But you? Youll be forgotten. Your vision unrealized.',
        ' ',
		'FLOW-MATIC ORIGINS:',
        'THE BAD ENDING: forgotten...',
        'Created by HTL-LEONDING students ADRIAN PICHLER and SEBASTIAN SCHNEIDERBAUER.'
	]), (write(Line), nl)).

print_question(a1, S) :-
	print_question(q1a, S).

% --- Answer Handling ---
handle_answer(q0, a, S) :-
	retract(dialogue_state(q0, S)),
	asserta(dialogue_state(q1a, S)),
	print_question(q1a, S).
handle_answer(q0, b, S) :-
	retract(dialogue_state(q0, S)),
	asserta(dialogue_state(q1b, S)),
	print_question(q1b, S).
handle_answer(q0, c, S0) :-
    S1 is S0 + 1,
    write('You hear silent mumbling from the committee.'), nl,
    retract(dialogue_state(q0, S0)),
    asserta(dialogue_state(q1a, S1)),
    print_question(q1a, S1).

handle_answer(a1, a, S) :- handle_answer(q1a, a, S).
handle_answer(a1, b, S) :- handle_answer(q1a, b, S).

handle_answer(q1a, a, S) :-
	retract(dialogue_state(q1a, S)),
	asserta(dialogue_state(q2a, S)),
	print_question(q2a, S).
handle_answer(q1a, b, S0) :-
	S1 is S0 + 1,
	write('You hear silent mumbling from the committee.'), nl,
	( S1 >= 2 -> end_bad
	; retract(dialogue_state(q1a, S0)),
	  asserta(dialogue_state(q2a, S1)),
	  print_question(q2a, S1)
	).

handle_answer(q1b, a, S0) :-
	S1 is S0 + 1,
	write('You hear silent mumbling from the committee.'), nl,
	( S1 >= 2 -> end_bad
	; retract(dialogue_state(q1b, S0)),
	  asserta(dialogue_state(q2b, S1)),
	  print_question(q2b, S1)
	).
handle_answer(q1b, b, S) :-
	retract(dialogue_state(q1b, S)),
	asserta(dialogue_state(q2b, S)),
	print_question(q2b, S).

handle_answer(q2a, a, _) :- end_good.
handle_answer(q2a, b, S0) :-
	S1 is S0 + 1,
	write('You hear silent mumbling from the committee.'), nl,
	end_bad_if_needed(S1).

handle_answer(q2b, a, S0) :-
	S1 is S0 + 1,
	write('You hear silent mumbling from the committee.'), nl,
	end_bad_if_needed(S1).
handle_answer(q2b, b, _) :- end_good.

% --- Endings ---
end_good :-
	retractall(dialogue_state(_, _)),
	print_question(end_good, 0).
end_bad_if_needed(S) :-
	( S >= 2 -> end_bad ; end_bad ).
end_bad :-
	retractall(dialogue_state(_, _)),
	print_question(end_bad, 0).

% --- Fallback ---
handle_answer(_, _, _) :-
	write('Invalid option. Please answer with a, b, or c.'), nl,
	dialogue_state(Q, S),
	print_question(Q, S).
