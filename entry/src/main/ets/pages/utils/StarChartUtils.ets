// utils/StarChartUtils.ets
import { HistoryNode } from '../../models/HistoryData'

// 显式定义点接口
export interface Point {
  x: number;
  y: number;
}

export interface StarDust {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  opacity: number;
}

// 显式定义经纬线接口
export interface GridLine {
  p1: Point;
  p2: Point;
}

// 视觉节点接口
export interface VisualNode extends HistoryNode {
  nodeColor: string;
}

export class StarChartProvider {
  /**
   * 生成历史节点（分段随机路径 + Catmull-Rom 平滑插值）
   */
  static generateStarNodes(
    rawNodes: HistoryNode[],
    containerWidth: number,
    containerHeight: number
  ): VisualNode[] {
    const count = rawNodes.length
    let result: VisualNode[] = []

    const centerX = containerWidth / 2
    const stepY = containerHeight / (count + 1)
    const amplitude = containerWidth * 0.25

    // ====== 1. 分段随机锚点 ======
    const segmentSize = 4
    let anchors: number[] = []
    for (let i = 0; i < Math.ceil(count / segmentSize) + 1; i++) {
      anchors.push((Math.random() * 2 - 1) * amplitude)
    }

    // ====== 2. 生成原始节点点坐标 ======
    let rawPoints: Point[] = []
    for (let i = 0; i < count; i++) {
      const segIndex = Math.floor(i / segmentSize)
      const localT = (i % segmentSize) / segmentSize
      const t = localT * localT * (3 - 2 * localT) // smoothstep
      const offsetX = anchors[segIndex] * (1 - t) + anchors[segIndex + 1] * t
      const x = centerX + offsetX
      const y = (i + 1) * stepY
      rawPoints.push({ x, y })
    }

    // ====== 3. Catmull-Rom 插值平滑曲线 ======
    let smoothPoints: Point[] = []
    for (let i = 0; i < rawPoints.length; i++) {
      const p0: Point = i - 1 < 0 ? rawPoints[0] : rawPoints[i - 1]
      const p1: Point = rawPoints[i]
      const p2: Point = i + 1 >= rawPoints.length ? rawPoints[rawPoints.length - 1] : rawPoints[i + 1]
      const p3: Point = i + 2 >= rawPoints.length ? rawPoints[rawPoints.length - 1] : rawPoints[i + 2]

      const segments = 4
      for (let j = 0; j < segments; j++) {
        const t = j / segments
        const t2 = t * t
        const t3 = t2 * t
        const x =
          0.5 *
            ((2 * p1.x) +
              (-p0.x + p2.x) * t +
              (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
              (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3)
        const y =
          0.5 *
            ((2 * p1.y) +
              (-p0.y + p2.y) * t +
              (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
              (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3)
        smoothPoints.push({ x, y })
      }
    }

    // ====== 4. 生成 VisualNode ======
    for (let i = 0; i < count; i++) {
      const item = rawNodes[i]
      const p: Point = smoothPoints[i * 4]

      let color = '#007DFF'
      const yearInt = parseInt(item.year)
      if (yearInt < 1840) color = '#FFB800'
      else if (yearInt < 1949) color = '#00E5FF'

      result.push({
        id: item.id,
        era: item.era,
        year: item.year,
        siteName: item.siteName,
        description: item.description,
        image: item.image,
        isExpanded: item.isExpanded,
        screenX: p.x,
        screenY: p.y,
        status: 'breath',
        nodeColor: color
      })
    }

    return result
  }

  /**
   * 星尘背景
   */
  static generateStarDust(count: number, w: number, h: number): StarDust[] {
    let dusts: StarDust[] = [];
    for (let i = 0; i < count; i++) {
      dusts.push({
        x: Math.random() * w,
        y: Math.random() * h,
        vx: (Math.random() - 0.5) * 0.15,
        vy: (Math.random() - 0.5) * 0.15,
        size: Math.random() * 3.5 + 1.2,
        opacity: Math.random() * 0.6 + 0.3
      });
    }
    return dusts;
  }

  /**
   * 时空经纬网
   */
  static generateGridLines(w: number, h: number): GridLine[] {
    let lines: GridLine[] = [];
    // [修改] 纵线每 80vp
    for (let x = 0; x <= w; x += 80) {
      lines.push({ p1: { x, y: 0 }, p2: { x, y: h } });
    }
    // [修改] 横线每 160vp
    for (let y = 0; y <= h; y += 160) {
      lines.push({ p1: { x: 0, y }, p2: { x: w, y } });
    }
    return lines;
  }
}
