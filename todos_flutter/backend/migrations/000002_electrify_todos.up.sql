BEGIN;
	SELECT electric.migration_version('000002');
	CALL electric.electrify('todolist');
	CALL electric.electrify('todo');
COMMIT;