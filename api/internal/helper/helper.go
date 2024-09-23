package helper

import (
	"fmt"
	"reflect"
)

func RemoveDuplicates(slice interface{}, fieldName string) interface{} {
	// Use reflection to get the value of the slice
	value := reflect.ValueOf(slice)

	// Check if it's a slice
	if value.Kind() != reflect.Slice {
		panic("removeDuplicates: provided value is not a slice")
	}

	// Create a map to track seen field values
	seen := make(map[interface{}]bool)
	uniqueSlice := reflect.MakeSlice(value.Type(), 0, value.Len())

	// Iterate through the slice
	for i := 0; i < value.Len(); i++ {
		// Get the struct
		item := value.Index(i)

		// Get the field value using reflection
		field := item.FieldByName(fieldName)

		// If the field doesn't exist or is unexported, panic
		if !field.IsValid() {
			panic(fmt.Sprintf("removeDuplicates: no such field: %s", fieldName))
		}

		// Convert field value to an interface{} to store in the map
		fieldValue := field.Interface()

		// If the field value is not in the seen map, add the item to the unique slice
		if !seen[fieldValue] {
			uniqueSlice = reflect.Append(uniqueSlice, item)
			seen[fieldValue] = true
		}
	}

	// Return the unique slice
	return uniqueSlice.Interface()
}
