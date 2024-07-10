package service

import (
	"testing"

	"github.com/google/uuid"
	"github.com/pidanou/librairian/internal/types"
	"github.com/stretchr/testify/assert"
)

func TestAddFile(t *testing.T) {
	testCases := []struct {
		description string
		file        *types.File
		want        *uuid.UUID
	}{
		{
			description: "File is nil",
			file:        &types.File{},
			want:        nil,
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.description, func(t *testing.T) {
			uuid, _ := testArchiveService.AddFile(testCase.file)
			assert.Equal(t, testCase.want, uuid)
		})
	}
}
