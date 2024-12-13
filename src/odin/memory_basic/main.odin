package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Game_Entity :: struct {
	name:   string,
	health: u32,
}

Game_Entity_Error :: enum {
	None,
	AllocationFailed,
	Failed,
}

game_entity_make :: proc(
	name: string,
	$health: u32, // Dollar sign denotes compile time constant
	allocator := context.allocator, // Unnecessary, but for demonstration purposes, see https://odin-lang.org/docs/overview/#implicit-context-system
) -> (
	entity: ^Game_Entity = nil,
	err: Game_Entity_Error = .None,
) {
	context.allocator = allocator
	entity_new, alloc_err := new(Game_Entity)
	if alloc_err != nil {
		return nil, .AllocationFailed
	}

	entity = entity_new
	entity.name = name
	entity.health = health
	return
}

game_entity_destroy_many :: proc(entities: [dynamic]^Game_Entity, allocator := context.allocator) {
	context.allocator = allocator
	fmt.printfln("Destroying %v entities", len(entities))

	for i := 0; i < len(entities); i += 1 {
		game_entity_destroy_one(entities[i])
	}
}

game_entity_destroy_one :: proc(entity: ^Game_Entity, allocator := context.allocator) {
	context.allocator = allocator
	fmt.printfln("Destroying entity %v", entity.name)

	free(entity)
}

game_entity_destroy :: proc {
	game_entity_destroy_one,
	game_entity_destroy_many,
}

main :: proc() {
	entities_len_arg: string = os.args[1] if len(os.args) > 1 else "5"
	entities_len: int = strconv.parse_int(entities_len_arg) or_else 5

	if entities_len < 0 {
		fmt.eprintf("Invalid number of entities: %v\n", entities_len)
		return
	}

	fmt.printfln("Creating %v entities", entities_len)

	entities := [dynamic]^Game_Entity{}
	defer delete(entities)

	allocation_err := reserve_dynamic_array(&entities, entities_len)
	if allocation_err != nil {
		fmt.eprintf("Failed to allocate entities\n")
		return
	}

	for i := 0; i < entities_len; i += 1 {
		entity_name := fmt.aprintf("Game_Entity_%d", i)
		entity, err := game_entity_make(entity_name, 100)

		if err != nil {
			fmt.eprintf("Failed to create entity\n")
			return
		}

		append(&entities, entity)
	}
	defer game_entity_destroy(entities)

	for i := 0; i < entities_len; i += 1 {
		fmt.printfln("Iterating over entity: %v, %v", entities[i].name, entities[i].health)
	}
}
