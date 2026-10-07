#!/usr/bin/env python3
"""Generate the Doctor Bike splash RML from the traced layered SVG."""

from __future__ import annotations

import argparse
import math
import re
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path


WIDTH = 821.0
HEIGHT = 859.0
CENTER_X = WIDTH / 2
CENTER_Y = HEIGHT / 2
ARTBOARD_WIDTH = 1080
ARTBOARD_HEIGHT = 1920
PURPLE = "FF6B65BD"
NAVY = "FF0F0F31"
BLACK = "FF000000"
WHITE = "FFFFFFFF"

GROUP_IDS = {
    "rear_wheel": "0:101",
    "front_wheel": "0:102",
    "lightning": "0:103",
    "front_arch": "0:104",
    "handlebar_stem": "0:105",
    "handlebar_top": "0:106",
    "wordmark": "0:107",
    "tagline": "0:108",
}


@dataclass
class Vertex:
    x: float
    y: float
    in_handle: tuple[float, float] | None = None
    out_handle: tuple[float, float] | None = None


@dataclass
class Contour:
    vertices: list[Vertex]
    closed: bool = False


TOKEN_RE = re.compile(r"([MLQZ])|(-?(?:\d+(?:\.\d*)?|\.\d+))")


def fmt(value: float) -> str:
    rounded = round(value, 3)
    if rounded == int(rounded):
        return str(int(rounded))
    return f"{rounded:.3f}".rstrip("0").rstrip(".")


def parse_path(data: str) -> list[Contour]:
    tokens = [match.group(0) for match in TOKEN_RE.finditer(data)]
    contours: list[Contour] = []
    current: Contour | None = None
    command = ""
    index = 0

    def number() -> float:
        nonlocal index
        value = float(tokens[index])
        index += 1
        return value

    while index < len(tokens):
        token = tokens[index]
        if token in {"M", "L", "Q", "Z"}:
            command = token
            index += 1
        if command == "M":
            current = Contour([Vertex(number(), number())])
            contours.append(current)
            command = "L"
        elif command == "L":
            if current is None:
                raise ValueError("Line command before move command")
            current.vertices.append(Vertex(number(), number()))
        elif command == "Q":
            if current is None:
                raise ValueError("Curve command before move command")
            control = (number(), number())
            end = (number(), number())
            start = current.vertices[-1]
            start.out_handle = (
                start.x + (2 / 3) * (control[0] - start.x),
                start.y + (2 / 3) * (control[1] - start.y),
            )
            current.vertices.append(
                Vertex(
                    end[0],
                    end[1],
                    in_handle=(
                        end[0] + (2 / 3) * (control[0] - end[0]),
                        end[1] + (2 / 3) * (control[1] - end[1]),
                    ),
                )
            )
        elif command == "Z":
            if current is None:
                raise ValueError("Close command before move command")
            current.closed = True
            command = ""
        else:
            raise ValueError(f"Unsupported SVG path command: {command!r}")
    return contours


def area(contour: Contour) -> float:
    points = contour.vertices
    return sum(
        points[index].x * points[(index + 1) % len(points)].y
        - points[(index + 1) % len(points)].x * points[index].y
        for index in range(len(points))
    ) / 2


def handle_attributes(
    vertex: Vertex,
    *,
    offset_x: float,
    offset_y: float,
) -> str:
    values: list[str] = []
    for prefix, handle in (("in", vertex.in_handle), ("out", vertex.out_handle)):
        if handle is None:
            rotation = distance = 0.0
        else:
            dx = handle[0] - vertex.x
            dy = handle[1] - vertex.y
            rotation = math.atan2(dy, dx)
            distance = math.hypot(dx, dy)
        values.append(f'{prefix}Rotation="{fmt(rotation)}"')
        values.append(f'{prefix}Distance="{fmt(distance)}"')
    return " ".join(values)


def points_paths(
    contours: list[Contour],
    *,
    offset_x: float = CENTER_X,
    offset_y: float = CENTER_Y,
    indent: str = "",
) -> list[str]:
    output: list[str] = []
    for contour_index, contour in enumerate(contours, start=1):
        clockwise = "true" if area(contour) > 0 else "false"
        output.append(
            f'{indent}<PointsPath isClosed="{str(contour.closed).lower()}" '
            f'isClockwise="{clockwise}" name="Contour {contour_index}">'
        )
        for vertex in contour.vertices:
            x = vertex.x - offset_x
            y = vertex.y - offset_y
            if vertex.in_handle is None and vertex.out_handle is None:
                output.append(
                    f'{indent}    <StraightVertex x="{fmt(x)}" y="{fmt(y)}"/>'
                )
            else:
                attrs = handle_attributes(
                    vertex,
                    offset_x=offset_x,
                    offset_y=offset_y,
                )
                output.append(
                    f'{indent}    <CubicDetachedVertex x="{fmt(x)}" '
                    f'y="{fmt(y)}" {attrs}/>'
                )
        output.append(f"{indent}</PointsPath>")
    return output


def filled_shape(
    name: str,
    contours: list[Contour],
    color: str,
    *,
    offset_x: float = CENTER_X,
    offset_y: float = CENTER_Y,
    indent: str = "",
) -> list[str]:
    lines = [f'{indent}<Shape name="{name} Shape">']
    lines.extend(
        points_paths(
            contours,
            offset_x=offset_x,
            offset_y=offset_y,
            indent=indent + "    ",
        )
    )
    lines.extend(
        [
            f'{indent}    <Fill fillRule="evenOdd" name="{name} Fill">',
            f'{indent}        <SolidColor colorValue="{color}" name="Color"/>',
            f"{indent}    </Fill>",
            f"{indent}</Shape>",
        ]
    )
    return lines


def traced_shape(name: str, contours: list[Contour], indent: str = "") -> list[str]:
    lines = [f'{indent}<Shape name="{name} Energy Trace">']
    lines.extend(points_paths(contours, indent=indent + "    "))
    lines.extend(
        [
            f'{indent}    <Stroke thickness="10" cap="round" join="round" name="Glow">',
            f'{indent}        <SolidColor colorValue="806B65BD" name="Color"/>',
            f'{indent}        <Feather strength="9" name="Soft Glow"/>',
            f'{indent}        <TargetEffect targetId="0:122" name="Wheel Reveal"/>',
            f"{indent}    </Stroke>",
            f'{indent}    <Stroke thickness="3" cap="round" join="round" name="Crisp">',
            f'{indent}        <SolidColor colorValue="FF8B80F9" name="Color"/>',
            f'{indent}        <TargetEffect targetId="0:122" name="Wheel Reveal"/>',
            f"{indent}    </Stroke>",
            f"{indent}</Shape>",
        ]
    )
    return lines


def ease(kind: str) -> tuple[float, float, float, float]:
    if kind == "out":
        return (0.215, 0.61, 0.355, 1.0)
    if kind == "inout":
        return (0.645, 0.045, 0.355, 1.0)
    raise ValueError(kind)


def keyed_property(
    property_key: int,
    keyframes: list[tuple[int, float, str]],
    indent: str,
) -> list[str]:
    lines = [f'{indent}<KeyedProperty propertyKey="{property_key}">']
    for frame, value, interpolation in keyframes:
        if interpolation in {"out", "inout"}:
            x1, y1, x2, y2 = ease(interpolation)
            lines.append(
                f'{indent}    <KeyFrameDouble value="{fmt(value)}" frame="{frame}" '
                'interpolationType="cubic">'
            )
            lines.append(
                f'{indent}        <CubicEaseInterpolator x1="{x1}" y1="{y1}" '
                f'x2="{x2}" y2="{y2}"/>'
            )
            lines.append(f"{indent}    </KeyFrameDouble>")
        else:
            lines.append(
                f'{indent}    <KeyFrameDouble value="{fmt(value)}" frame="{frame}" '
                f'interpolationType="{interpolation}"/>'
            )
    lines.append(f"{indent}</KeyedProperty>")
    return lines


def keyed_object(
    object_id: str,
    properties: dict[int, list[tuple[int, float, str]]],
    indent: str = "            ",
) -> list[str]:
    lines = [f'{indent}<KeyedObject objectId="{object_id}">']
    for property_key, keyframes in properties.items():
        lines.extend(keyed_property(property_key, keyframes, indent + "    "))
    lines.append(f"{indent}</KeyedObject>")
    return lines


def simple_line(
    name: str,
    start: tuple[float, float],
    end: tuple[float, float],
    indent: str,
) -> list[str]:
    return [
        f'{indent}<Shape name="{name}">',
        f'{indent}    <PointsPath isClosed="false" isClockwise="true" name="Path">',
        f'{indent}        <StraightVertex x="{fmt(start[0])}" y="{fmt(start[1])}"/>',
        f'{indent}        <StraightVertex x="{fmt(end[0])}" y="{fmt(end[1])}"/>',
        f"{indent}    </PointsPath>",
        f'{indent}    <Stroke thickness="3" cap="round" name="Stroke">',
        f'{indent}        <SolidColor colorValue="B36B65BD" name="Color"/>',
        f'{indent}        <Feather strength="3" name="Glow"/>',
        f"{indent}    </Stroke>",
        f"{indent}</Shape>",
    ]


def load_logo(svg_path: Path) -> dict[str, tuple[list[Contour], str]]:
    root = ET.parse(svg_path).getroot()
    namespace = {"svg": "http://www.w3.org/2000/svg"}
    result: dict[str, tuple[list[Contour], str]] = {}
    for group in root.findall("svg:g", namespace):
        group_id = group.get("id")
        path = group.find("svg:path", namespace)
        if group_id in GROUP_IDS and path is not None:
            result[group_id] = (
                parse_path(path.attrib["d"]),
                "FF" + path.attrib["fill"].lstrip("#").upper(),
            )
    missing = set(GROUP_IDS) - set(result)
    if missing:
        raise ValueError(f"Missing SVG groups: {', '.join(sorted(missing))}")
    return result


def build_scene(logo: dict[str, tuple[list[Contour], str]]) -> str:
    lines = [
        '<Rive version="1" kind="fragment">',
        '    <Artboard defaultStateMachineId="0:7" styleId="0:5" '
        f'width="{ARTBOARD_WIDTH}" height="{ARTBOARD_HEIGHT}" '
        'name="Doctor Bike Splash" id="0:2">',
        '        <LayoutComponentStyle name="Artboard Style" id="0:5"/>',
        '        <Fill name="White Background">',
        f'            <SolidColor colorValue="{WHITE}" name="Color"/>',
        '        </Fill>',
        '',
        '        <GroupEffect name="Wheel Draw Effect" id="0:122">',
        '            <TrimPath start="0" end="0" modeValue="synchronized" '
        'name="Wheel Draw" id="0:121"/>',
        '        </GroupEffect>',
        '',
        '        <Node x="540" y="825" opacity="0" scaleX="0.18" '
        'scaleY="0.18" name="Energy Spark" id="0:130">',
        '            <Shape name="Spark Core">',
        '                <Ellipse width="36" height="36" name="Path"/>',
        '                <Fill fillRule="clockwise" name="Glow">',
        '                    <SolidColor colorValue="806B65BD" name="Color"/>',
        '                    <Feather strength="24" name="Feather"/>',
        '                </Fill>',
        '                <Fill name="Core">',
        '                    <SolidColor colorValue="FFFDFBFF" name="Color"/>',
        '                </Fill>',
        '            </Shape>',
        '            <Shape rotation="0.34" name="Energy Orbit 1">',
        '                <Ellipse width="210" height="74" name="Path"/>',
        '                <Stroke thickness="3" cap="round" name="Glow">',
        '                    <SolidColor colorValue="A06B65BD" name="Color"/>',
        '                    <Feather strength="5" name="Feather"/>',
        '                </Stroke>',
        '                <Stroke thickness="1.6" cap="round" name="Crisp">',
        '                    <SolidColor colorValue="FF8B80F9" name="Color"/>',
        '                </Stroke>',
        '            </Shape>',
        '            <Shape rotation="-0.5" name="Energy Orbit 2">',
        '                <Ellipse width="152" height="52" name="Path"/>',
        '                <Stroke thickness="1.8" cap="round" name="Stroke">',
        '                    <SolidColor colorValue="D06B65BD" name="Color"/>',
        '                    <Feather strength="3" name="Feather"/>',
        '                </Stroke>',
        '            </Shape>',
    ]
    for index, (start, end) in enumerate(
        [
            ((0, -42), (0, -86)),
            ((31, -31), (61, -61)),
            ((44, 0), (91, 0)),
            ((31, 31), (66, 66)),
            ((0, 42), (0, 91)),
            ((-31, 31), (-67, 67)),
            ((-44, 0), (-91, 0)),
            ((-31, -31), (-66, -66)),
        ],
        start=1,
    ):
        lines.extend(simple_line(f"Spark Ray {index}", start, end, "            "))
    for index, (x, y, size) in enumerate(
        [(-118, -54, 8), (-91, 64, 6), (-54, -103, 5), (74, -90, 7),
         (117, -18, 6), (98, 73, 5), (45, 112, 7), (-121, 21, 5)],
        start=1,
    ):
        lines.extend(
            [
                f'            <Shape x="{x}" y="{y}" name="Particle {index}">',
                f'                <Ellipse width="{size}" height="{size}" name="Path"/>',
                '                <Fill fillRule="clockwise" name="Glow">',
                '                    <SolidColor colorValue="CC7D70F5" name="Color"/>',
                '                    <Feather strength="4" name="Feather"/>',
                '                </Fill>',
                '                <Fill name="Core">',
                '                    <SolidColor colorValue="FFFFFFFF" name="Color"/>',
                '                </Fill>',
                '            </Shape>',
            ]
        )
    lines.extend(['        </Node>', ''])

    lines.extend(
        [
            '        <Node x="540" y="960" scaleX="0.95" scaleY="0.95" '
            'opacity="0" name="Wheel Energy" id="0:120">'
        ]
    )
    lines.extend(traced_shape("Rear Wheel", logo["rear_wheel"][0], "            "))
    lines.extend(traced_shape("Front Wheel", logo["front_wheel"][0], "            "))
    lines.extend(['        </Node>', ''])

    lines.extend(
        [
            '        <Node x="540" y="960" name="Logo Settle" id="0:20">',
            '            <Node scaleX="0.95" scaleY="0.95" name="Logo Geometry">',
        ]
    )

    lightning_contours, lightning_color = logo["lightning"]
    lightning_pivot = min(vertex.x for contour in lightning_contours for vertex in contour.vertices)
    lightning_x = lightning_pivot - CENTER_X
    for group_id in (
        "lightning",
        "front_arch",
        "handlebar_stem",
        "handlebar_top",
        "rear_wheel",
        "front_wheel",
        "wordmark",
        "tagline",
    ):
        contours, color = logo[group_id]
        node_id = GROUP_IDS[group_id]
        if group_id == "lightning":
            lines.append(
                f'                <Node x="{fmt(lightning_x)}" name="lightning" id="{node_id}">'
            )
            lines.extend(
                filled_shape(
                    "lightning",
                    contours,
                    color,
                    offset_x=lightning_pivot,
                    indent="                    ",
                )
            )
        else:
            lines.append(f'                <Node name="{group_id}" id="{node_id}">')
            lines.extend(
                filled_shape(group_id, contours, color, indent="                    ")
            )
        lines.append('                </Node>')

        if group_id == "lightning":
            for trail_index, trail_x, trail_opacity in (
                (1, lightning_x - 52, 0.22),
                (2, lightning_x - 92, 0.12),
            ):
                trail_id = f"0:{150 + trail_index}"
                lines.append(
                    f'                <Node x="{fmt(trail_x)}" opacity="{trail_opacity}" '
                    f'name="Lightning Trail {trail_index}" id="{trail_id}">'
                )
                lines.extend(
                    filled_shape(
                        f"Lightning Trail {trail_index}",
                        contours,
                        lightning_color,
                        offset_x=lightning_pivot,
                        indent="                    ",
                    )
                )
                lines.append('                </Node>')

    lines.extend(
        [
            '                <Node y="-115" opacity="0" name="Logo Lock Glow" id="0:140">',
            '                    <Shape name="Glow Ring">',
            '                        <Ellipse width="760" height="430" name="Path"/>',
            '                        <Stroke thickness="10" name="Glow">',
            '                            <SolidColor colorValue="606B65BD" name="Color"/>',
            '                            <Feather strength="28" name="Feather"/>',
            '                        </Stroke>',
            '                    </Shape>',
            '                </Node>',
            '            </Node>',
            '        </Node>',
            '',
            '        <Shape x="540" y="960" name="White Background Shape">',
            '            <Rectangle width="1080" height="1920" originX="0.5" '
            'originY="0.5" name="Path"/>',
            '            <Fill name="Fill">',
            f'                <SolidColor colorValue="{WHITE}" name="Color"/>',
            '            </Fill>',
            '        </Shape>',
            '',
            '        <StateMachine name="Splash State Machine" id="0:7">',
            '            <StateMachineLayer name="Autoplay" id="0:8">',
            '                <AnyState x="200" y="-120"/>',
            '                <ExitState x="400" y="-120"/>',
            '                <EntryState>',
            '                    <StateTransition stateToId="0:12"/>',
            '                </EntryState>',
            '                <AnimationState x="200" y="0" animationId="0:6" '
            'reset="true" id="0:12"/>',
            '            </StateMachineLayer>',
            '        </StateMachine>',
            '',
            '        <LinearAnimation fps="60" duration="192" loopValue="oneShot" '
            'name="Doctor Bike Splash" id="0:6">',
        ]
    )

    lines.extend(
        keyed_object(
            "0:130",
            {
                18: [(0, 0, "out"), (6, 1, "out"), (22, 1, "hold"), (38, 0, "out")],
                16: [(0, 0.18, "out"), (12, 0.88, "out"), (38, 1.35, "linear")],
                17: [(0, 0.18, "out"), (12, 0.88, "out"), (38, 1.35, "linear")],
                15: [(0, -0.28, "out"), (38, 0.24, "linear")],
            },
        )
    )
    lines.extend(
        keyed_object(
            "0:121", {115: [(0, 0, "hold"), (22, 0, "out"), (66, 1, "linear")]}
        )
    )
    lines.extend(
        keyed_object(
            "0:120",
            {18: [(0, 0, "hold"), (16, 0, "out"), (24, 1, "hold"), (68, 1, "out"), (80, 0, "linear")]},
        )
    )
    for wheel_id in ("0:101", "0:102"):
        lines.extend(
            keyed_object(
                wheel_id,
                {18: [(0, 0, "hold"), (56, 0, "out"), (74, 1, "linear")]},
            )
        )
    lines.extend(
        keyed_object(
            "0:103",
            {
                18: [(0, 0, "hold"), (54, 0, "out"), (94, 1, "linear")],
                13: [(0, lightning_x - 82, "hold"), (54, lightning_x - 82, "out"), (98, lightning_x, "linear")],
                16: [(0, 0.05, "hold"), (54, 0.05, "out"), (98, 1, "linear")],
            },
        )
    )
    for trail_id, start_x, end_frame in (
        ("0:151", lightning_x - 108, 102),
        ("0:152", lightning_x - 154, 106),
    ):
        lines.extend(
            keyed_object(
                trail_id,
                {
                    18: [(0, 0, "hold"), (54, 0, "out"), (66, 0.25, "out"), (end_frame, 0, "linear")],
                    13: [(0, start_x, "hold"), (54, start_x, "out"), (end_frame, lightning_x, "linear")],
                },
            )
        )
    for node_id, start_frame, y_offset in (
        ("0:104", 84, 24),
        ("0:105", 94, 34),
        ("0:106", 104, 30),
    ):
        lines.extend(
            keyed_object(
                node_id,
                {
                    18: [(0, 0, "hold"), (start_frame, 0, "out"), (start_frame + 26, 1, "linear")],
                    14: [(0, y_offset, "hold"), (start_frame, y_offset, "out"), (start_frame + 26, 0, "linear")],
                },
            )
        )
    lines.extend(
        keyed_object(
            "0:107",
            {
                18: [(0, 0, "hold"), (112, 0, "out"), (138, 1, "linear")],
                14: [(0, 16, "hold"), (112, 16, "out"), (138, 0, "linear")],
            },
        )
    )
    lines.extend(
        keyed_object(
            "0:108",
            {
                18: [(0, 0, "hold"), (130, 0, "out"), (150, 1, "linear")],
                14: [(0, 18, "hold"), (130, 18, "out"), (150, 0, "linear")],
            },
        )
    )
    lines.extend(
        keyed_object(
            "0:20",
            {
                16: [(0, 1.02, "hold"), (126, 1.02, "inout"), (146, 1, "linear")],
                17: [(0, 1.02, "hold"), (126, 1.02, "inout"), (146, 1, "linear")],
            },
        )
    )
    lines.extend(
        keyed_object(
            "0:140",
            {18: [(0, 0, "hold"), (126, 0, "inout"), (136, 0.18, "inout"), (152, 0, "linear")]},
        )
    )
    lines.extend(['        </LinearAnimation>', '    </Artboard>', '</Rive>', ''])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--svg", type=Path, default=Path("doctor_bike_logo_rive.svg"))
    parser.add_argument("--output", type=Path, default=Path("scene.rml"))
    args = parser.parse_args()
    logo = load_logo(args.svg)
    args.output.write_text(build_scene(logo), encoding="utf-8", newline="\n")
    print(f"Generated {args.output} from {args.svg}")


if __name__ == "__main__":
    main()
