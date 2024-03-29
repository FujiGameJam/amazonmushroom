module camera.camera;

import fuji.view;
import fuji.display;

import interfaces.entity;

import std.math;

class Camera
{
	MFMatrix transform;
	protected float	nearPlane = 0.01,
					farPlane = 100000;
	protected float fov = MFDeg2Rad!60;

	@property MFVector Position() { return transform.t; }
	@property MFVector Position(MFVector pos) { return (transform.t = pos); }

	@property float NearPlane() { return nearPlane; }
	@property float NearPlane(float p) { return (nearPlane = p); }

	@property float FarPlane() { return farPlane; }
	@property float FarPlane(float p) { return (farPlane = p); }

	@property float FOV() { return fov; }
	@property float FOV(float rad) { return (fov = rad); }

	@property float HorizontalFOV()
	{
		return 2 * atan(tan(fov / 2) * XAspect);
	}

	@property float XAspect()
	{
		MFRect rect;
		MFDisplay_GetDisplayRect(&rect);

		return cast(float) rect.width / cast(float) rect.height;
	}

	@property float YAspect()
	{
		MFRect rect;
		MFDisplay_GetDisplayRect(&rect);

		return cast(float) rect.height / cast(float) rect.width;
	}

	void Apply(MFVector offset)
	{
		MFView_ConfigureProjection(fov, nearPlane, farPlane);
		MFView_SetAspectRatio(XAspect);
		MFView_SetProjection();
		MFMatrix mat = transform;
		mat.t += offset;
		MFView_SetCameraMatrix(mat);
	}

}
