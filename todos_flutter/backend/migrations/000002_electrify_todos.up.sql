BEGIN;
	CALL electric.electrify('todolist');
	CALL electric.electrify('todo');
COMMIT;