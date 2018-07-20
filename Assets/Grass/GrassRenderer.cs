using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GrassRenderer : MonoBehaviour {

    private Mesh mesh;
    public Material material;
    public MeshFilter filter;
    public GameObject windZone;

    public int seed;

    public Vector2 Size;
    [Range(1, 100000)]
    public int grassNumber;

    public float startHeight = 1000;
    public float grassoffset = 0.0f;

    private List<Matrix4x4> materices;
    private Vector3 lastPosition;

    void Update () {

        //material.SetVector("_WindZone", windZone.transform.position);

        if (lastPosition == transform.position)
            return;
        lastPosition = transform.position;

        Random.InitState(seed);
        //materices = new List<Matrix4x4>(grassNumber);
        List<Vector3> positions = new List<Vector3>(grassNumber);
        int[] indicies = new int[grassNumber];
        List<Color> colors = new List<Color>(grassNumber);
        List<Vector3> normals = new List<Vector3>(grassNumber);

        for (int i = 0; i < grassNumber; i++)
        {
            Vector3 origin = transform.position;
            origin.y = startHeight;
            origin.x += Size.x * Random.Range(-0.5f, 0.5f);
            origin.z += Size.y * Random.Range(-0.5f, 0.5f);
            Ray ray = new Ray(origin, Vector3.down);
            Debug.DrawRay(origin, Vector3.down, Color.red);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                origin = hit.point;
                origin.y += grassoffset;

                //materices.Add(Matrix4x4.TRS(origin, Quaternion.identity, Vector3.one));
                positions.Add(origin);
                indicies[i] = i;
                colors.Add(new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1.0f));
                normals.Add(hit.normal);
            }
        }

        mesh = new Mesh();
        mesh.SetVertices(positions);
        mesh.SetIndices(indicies, MeshTopology.Points, 0);
        mesh.SetColors(colors);
        mesh.SetNormals(normals);
        filter.mesh = mesh;

        //Graphics.DrawMeshInstanced(grassMesh, 0, material, materices);
	}
}
