package main

import "core:fmt"
import "core:reflect"

Root_Component :: struct {
	id: u32,
}

Component :: struct {
	using root: Root_Component,
	name:       string `rat:"do-some-magic"`,
}

main :: proc() {
	id := typeid_of(Component)
	component_names := reflect.struct_field_names(id)
	component_types := reflect.struct_field_types(id)
	component_tags := reflect.struct_field_tags(id)

	fmt.printfln("Component struct introspection:")

	for tag, i in component_tags {
		name, type := component_names[i], component_types[i]
		if tag != "" {
			fmt.printf(" - %s: %T with tag `%s`,\n", name, type, tag)
		} else {
			fmt.printf(" - %s: %T,\n", name, type)
		}
	}
}
