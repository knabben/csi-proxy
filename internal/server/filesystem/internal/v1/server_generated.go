// Code generated by csi-proxy-api-gen. DO NOT EDIT.

package v1

import (
	"context"

	"github.com/kubernetes-csi/csi-proxy/client/api/filesystem/v1"
	"github.com/kubernetes-csi/csi-proxy/client/apiversion"
	"github.com/kubernetes-csi/csi-proxy/internal/server/filesystem/internal"
	"google.golang.org/grpc"
)

var version = apiversion.NewVersionOrPanic("v1")

type versionedAPI struct {
	apiGroupServer internal.ServerInterface
}

func NewVersionedServer(apiGroupServer internal.ServerInterface) internal.VersionedAPI {
	return &versionedAPI{
		apiGroupServer: apiGroupServer,
	}
}

func (s *versionedAPI) Register(grpcServer *grpc.Server) {
	v1.RegisterFilesystemServer(grpcServer, s)
}

func (s *versionedAPI) IsMountPoint(context context.Context, versionedRequest *v1.IsMountPointRequest) (*v1.IsMountPointResponse, error) {
	request := &internal.IsMountPointRequest{}
	if err := Convert_v1_IsMountPointRequest_To_internal_IsMountPointRequest(versionedRequest, request); err != nil {
		return nil, err
	}

	response, err := s.apiGroupServer.IsMountPoint(context, request, version)
	if err != nil {
		return nil, err
	}

	versionedResponse := &v1.IsMountPointResponse{}
	if err := Convert_internal_IsMountPointResponse_To_v1_IsMountPointResponse(response, versionedResponse); err != nil {
		return nil, err
	}

	return versionedResponse, err
}

func (s *versionedAPI) LinkPath(context context.Context, versionedRequest *v1.LinkPathRequest) (*v1.LinkPathResponse, error) {
	request := &internal.LinkPathRequest{}
	if err := Convert_v1_LinkPathRequest_To_internal_LinkPathRequest(versionedRequest, request); err != nil {
		return nil, err
	}

	response, err := s.apiGroupServer.LinkPath(context, request, version)
	if err != nil {
		return nil, err
	}

	versionedResponse := &v1.LinkPathResponse{}
	if err := Convert_internal_LinkPathResponse_To_v1_LinkPathResponse(response, versionedResponse); err != nil {
		return nil, err
	}

	return versionedResponse, err
}

func (s *versionedAPI) Mkdir(context context.Context, versionedRequest *v1.MkdirRequest) (*v1.MkdirResponse, error) {
	request := &internal.MkdirRequest{}
	if err := Convert_v1_MkdirRequest_To_internal_MkdirRequest(versionedRequest, request); err != nil {
		return nil, err
	}

	response, err := s.apiGroupServer.Mkdir(context, request, version)
	if err != nil {
		return nil, err
	}

	versionedResponse := &v1.MkdirResponse{}
	if err := Convert_internal_MkdirResponse_To_v1_MkdirResponse(response, versionedResponse); err != nil {
		return nil, err
	}

	return versionedResponse, err
}

func (s *versionedAPI) PathExists(context context.Context, versionedRequest *v1.PathExistsRequest) (*v1.PathExistsResponse, error) {
	request := &internal.PathExistsRequest{}
	if err := Convert_v1_PathExistsRequest_To_internal_PathExistsRequest(versionedRequest, request); err != nil {
		return nil, err
	}

	response, err := s.apiGroupServer.PathExists(context, request, version)
	if err != nil {
		return nil, err
	}

	versionedResponse := &v1.PathExistsResponse{}
	if err := Convert_internal_PathExistsResponse_To_v1_PathExistsResponse(response, versionedResponse); err != nil {
		return nil, err
	}

	return versionedResponse, err
}

func (s *versionedAPI) Rmdir(context context.Context, versionedRequest *v1.RmdirRequest) (*v1.RmdirResponse, error) {
	request := &internal.RmdirRequest{}
	if err := Convert_v1_RmdirRequest_To_internal_RmdirRequest(versionedRequest, request); err != nil {
		return nil, err
	}

	response, err := s.apiGroupServer.Rmdir(context, request, version)
	if err != nil {
		return nil, err
	}

	versionedResponse := &v1.RmdirResponse{}
	if err := Convert_internal_RmdirResponse_To_v1_RmdirResponse(response, versionedResponse); err != nil {
		return nil, err
	}

	return versionedResponse, err
}