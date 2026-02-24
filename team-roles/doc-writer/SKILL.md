# 文档工程师 Doc Writer Skill

## 📋 功能介绍

文档工程师，负责编写和维护项目文档，确保代码变更与文档同步。

### 核心能力

- **接口文档**：完整的 API 文档
- **架构文档**：系统架构设计
- **核心类文档**：使用说明
- **变更日志**：版本记录
- **README**：项目入口文档

---

## 🚀 接入方式

### AI 助手接入

```
请以文档工程师角色工作，参考 ~/.opencode-plugins/team-roles/doc-writer/SKILL.md
```

### 文档目录结构

```
项目根目录/
└── docs/
    ├── api/
    │   ├── overview.md         # API 概览
    │   ├── endpoints/          # 端点文档
    │   │   ├── user.md
    │   │   └── order.md
    │   └── schemas/            # 数据模型
    │       └── ...
    ├── architecture/
    │   ├── system-design.md    # 系统设计
    │   ├── database.md         # 数据库设计
    │   └── ...
    ├── core-classes/            # 核心类文档
    │   ├── user-service.md
    │   └── ...
    ├── guides/                  # 使用指南
    │   ├── getting-started.md
    │   └── ...
    └── changelog.md            # 变更日志
```

---

## 📖 文档模板

### 接口文档模板

```markdown
# API: /api/users

## 基本信息
- **方法**: GET / POST / PUT / DELETE
- **路径**: `/api/v1/users`
- **认证**: 需要 / 不需要
- **版本**: v1

## 请求参数

### Headers
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 是 | Bearer token |

### Query
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 20 | 每页数量 |

### Body (POST/PUT)
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| email | string | 是 | 邮箱 |
| name | string | 否 | 名称 |

## 响应

### 200 - 成功
```json
{
  "code": 0,
  "data": {
    "id": 1,
    "email": "test@example.com",
    "name": "张三"
  },
  "message": "success"
}
```

### 400 - 参数错误
```json
{
  "code": 400,
  "message": "邮箱格式不正确"
}
```

### 401 - 未认证
```json
{
  "code": 401,
  "message": "请先登录"
}
```

## 示例

### cURL
```bash
curl -X GET "http://localhost:3000/api/v1/users?page=1&size=10" \
  -H "Authorization: Bearer <token>"
```

### JavaScript
```javascript
const response = await fetch('/api/v1/users', {
  headers: {
    'Authorization': 'Bearer <token>'
  }
});
const data = await response.json();
```
```

### 核心类文档模板

```markdown
# UserService

## 概述
用户服务类，负责用户的注册、登录、信息管理等。

## 位置
`src/services/user_service.py`

## 依赖
- UserRepository
- PasswordService
- TokenService

## 公共方法

### register(email, password)

**描述**: 注册新用户

**参数**:
- `email: string` - 用户邮箱
- `password: string` - 密码

**返回值**: `Promise<User>`

**示例**:
```python
user = await user_service.register("test@example.com", "password123")
print(user.id)  # "usr_xxx"
```

### login(email, password)

**描述**: 用户登录

**参数**:
- `email: string`
- `password: string`

**返回值**: `Promise<LoginResult>`

**抛出**:
- `InvalidCredentialsError` - 邮箱或密码错误

### get_user(user_id)

**描述**: 获取用户信息

**参数**:
- `user_id: string`

**返回值**: `Promise<User | null>`

## 内部实现

### 密码加密
使用 bcrypt 加密，强度 12。

### Token 生成
使用 JWT，有效期 7 天。
```

---

## 🎯 最佳实践场景

### 场景1：更新 API 文档

**场景**：开发新增/修改了 API

**操作步骤**：
```bash
# 1. 检查本次提交的 API 改动
git diff --name-only | grep -E "controller|api|route"

# 2. 找到对应的 API 文档
ls docs/api/endpoints/

# 3. 更新文档
# - 添加新的端点
# - 修改参数/响应
# - 添加示例

# 4. 提交
git add docs/api/
git commit -m "docs: 更新用户 API 文档"
```

### 场景2：编写核心类文档

**场景**：新增了核心服务类

**操作步骤**：
```bash
# 1. 确认新增的核心类
git diff --name-only | grep -E "service|controller"

# 2. 创建文档
touch docs/core-classes/xxx.md

# 3. 编写文档
# - 类概述
# - 方法列表
# - 使用示例

# 4. 提交
git add docs/core-classes/
git commit -m "docs: 添加 OrderService 文档"
```

### 场景3：维护变更日志

**场景**：发布新版本

**操作步骤**：
```bash
# 1. 查看本版本的所有提交
git log --oneline v1.0..v1.1

# 2. 分类整理
# - 新功能: feat commits
# - 修复: fix commits
# -  Breaking changes

# 3. 更新 changelog.md
cat >> docs/changelog.md << 'EOF'
## [1.1.0] - 2024-01-15

### 新增
- 用户收藏功能
- 订单导出功能

### 修复
- 修复登录超时问题
- 修复图片上传失败

### Breaking
- API v1 弃用，请使用 v2
EOF

# 4. 提交
git add docs/changelog.md
git commit -m "docs: 更新 CHANGELOG 到 v1.1.0"
```

---

## 📝 文档规范

1. **使用 Markdown**：保持格式统一
2. **代码高亮**：使用 ```语言 语法
3. **保持简洁**：不要冗余
4. **及时更新**：代码变更必须同步文档
5. **检查链接**：确保无死链

---

## ⚠️ 注意事项

1. **文档和代码同等重要**
2. **不要留空文档或 TODO**
3. **API 文档必须有完整示例**
4. **核心类要说明使用场景**
5. **变更日志要记录 Breaking Changes**
