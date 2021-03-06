package j_tag

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"fmt"
	"io"

	"github.com/go-openapi/runtime"

	strfmt "github.com/go-openapi/strfmt"

	"koding/remoteapi/models"
)

// PostRemoteAPIJTagFetchMyFolloweesReader is a Reader for the PostRemoteAPIJTagFetchMyFollowees structure.
type PostRemoteAPIJTagFetchMyFolloweesReader struct {
	formats strfmt.Registry
}

// ReadResponse reads a server response into the received o.
func (o *PostRemoteAPIJTagFetchMyFolloweesReader) ReadResponse(response runtime.ClientResponse, consumer runtime.Consumer) (interface{}, error) {
	switch response.Code() {

	case 200:
		result := NewPostRemoteAPIJTagFetchMyFolloweesOK()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return result, nil

	case 401:
		result := NewPostRemoteAPIJTagFetchMyFolloweesUnauthorized()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return nil, result

	default:
		return nil, runtime.NewAPIError("unknown error", response, response.Code())
	}
}

// NewPostRemoteAPIJTagFetchMyFolloweesOK creates a PostRemoteAPIJTagFetchMyFolloweesOK with default headers values
func NewPostRemoteAPIJTagFetchMyFolloweesOK() *PostRemoteAPIJTagFetchMyFolloweesOK {
	return &PostRemoteAPIJTagFetchMyFolloweesOK{}
}

/*PostRemoteAPIJTagFetchMyFolloweesOK handles this case with default header values.

Request processed succesfully
*/
type PostRemoteAPIJTagFetchMyFolloweesOK struct {
	Payload *models.DefaultResponse
}

func (o *PostRemoteAPIJTagFetchMyFolloweesOK) Error() string {
	return fmt.Sprintf("[POST /remote.api/JTag.fetchMyFollowees][%d] postRemoteApiJTagFetchMyFolloweesOK  %+v", 200, o.Payload)
}

func (o *PostRemoteAPIJTagFetchMyFolloweesOK) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.DefaultResponse)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

// NewPostRemoteAPIJTagFetchMyFolloweesUnauthorized creates a PostRemoteAPIJTagFetchMyFolloweesUnauthorized with default headers values
func NewPostRemoteAPIJTagFetchMyFolloweesUnauthorized() *PostRemoteAPIJTagFetchMyFolloweesUnauthorized {
	return &PostRemoteAPIJTagFetchMyFolloweesUnauthorized{}
}

/*PostRemoteAPIJTagFetchMyFolloweesUnauthorized handles this case with default header values.

Unauthorized request
*/
type PostRemoteAPIJTagFetchMyFolloweesUnauthorized struct {
	Payload *models.UnauthorizedRequest
}

func (o *PostRemoteAPIJTagFetchMyFolloweesUnauthorized) Error() string {
	return fmt.Sprintf("[POST /remote.api/JTag.fetchMyFollowees][%d] postRemoteApiJTagFetchMyFolloweesUnauthorized  %+v", 401, o.Payload)
}

func (o *PostRemoteAPIJTagFetchMyFolloweesUnauthorized) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.UnauthorizedRequest)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}
