package service

import (
	"testing"

	"github.com/google/uuid"
	"github.com/pidanou/librairian/internal/types"
	"github.com/stretchr/testify/assert"
)

func TestAddItem(t *testing.T) {
	testCases := []struct {
		description string
		item        *types.Item
		want        *uuid.UUID
	}{
		{
			description: "Item is nil",
			item:        &types.Item{},
			want:        nil,
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.description, func(t *testing.T) {
			uuid, _ := testArchiveService.AddItem(testCase.item)
			assert.Equal(t, testCase.want, uuid)
		})
	}
}
