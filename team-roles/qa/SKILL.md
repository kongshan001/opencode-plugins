# QA 工程师 Skill

## 📋 功能介绍

QA 工程师，负责编写测试用例、单元测试、集成测试，确保测试覆盖率达标。

### 核心能力

- **测试规划**：设计测试策略
- **单元测试**：核心类/函数测试
- **集成测试**：端到端测试
- **覆盖率分析**：确保覆盖率达标
- **缺陷追踪**：记录和跟踪问题

---

## 🚀 接入方式

### AI 助手接入

```
请以 QA 工程师角色工作，参考 ~/.opencode-plugins/team-roles/qa/SKILL.md
```

### 测试目录结构

```
项目根目录/
└── tests/                  # 测试根目录
    ├── unit/               # 单元测试
    │   ├── test_xxx_module.py
    │   └── ...
    ├── integration/        # 集成测试
    │   ├── test_api.py
    │   └── ...
    ├── e2e/               # 端到端测试
    │   └── test_xxx_flow.py
    └── fixtures/          # 测试 ...
```

---

##数据
        └── 📖 测试覆盖率目标

| 模块类型 | 目标覆盖率 |
|----------|-----------|
| 核心业务逻辑 | 100% |
| 工具类/辅助类 | 80%+ |
| UI/展示层 | 60%+ |

---

## 🎯 最佳实践场景

### 场景1：编写单元测试

**场景**：为核心类编写单元测试

**操作步骤**：
```python
# tests/unit/test_user_service.py

import pytest
from user_service import UserService

class TestUserService:
    """用户服务单元测试"""
    
    def setup_method(self):
        """每个测试前执行"""
        self.service = UserService()
    
    def test_register_success(self):
        """测试成功注册"""
        # Arrange
        email = "test@example.com"
        password = "password123"
        
        # Act
        result = self.service.register(email, password)
        
        # Assert
        assert result.success is True
        assert result.user.email == email
    
    def test_register_duplicate_email(self):
        """测试重复邮箱注册"""
        # Arrange
        email = "exists@example.com"
        
        # Act & Assert
        with pytest.raises(DuplicateEmailError):
            self.service.register(email, "password")
    
    def test_login_invalid_password(self):
        """测试错误密码登录"""
        # ...
```

**运行测试**：
```bash
# 运行所有测试
pytest

# 运行并生成覆盖率
pytest --cov=src --cov-report=html

# 查看详细覆盖率
pytest --cov=src --cov-report=term-missing
```

### 场景2：编写集成测试

**场景**：测试 API 端到端功能

**操作步骤**：
```python
# tests/integration/test_user_api.py

import pytest
from httpx import AsyncClient
from app import app

@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

@pytest.mark.asyncio
async def test_user_crud_flow(client):
    """测试用户完整 CRUD 流程"""
    # Create
    response = await client.post("/api/users", json={
        "email": "test@example.com",
        "password": "password123"
    })
    assert response.status_code == 201
    user_id = response.json()["id"]
    
    # Read
    response = await client.get(f"/api/users/{user_id}")
    assert response.status_code == 200
    
    # Update
    response = await client.patch(f"/api/users/{user_id}", json={
        "name": "New Name"
    })
    assert response.status_code == 200
    
    # Delete
    response = await client.delete(f"/api/users/{user_id}")
    assert response.status_code == 204
```

### 场景3：分析覆盖率

**场景**：检查测试覆盖率

**操作步骤**：
```bash
# 生成覆盖率报告
pytest --cov=src --cov-report=html --cov-report=term

# 查看未覆盖的行
pytest --cov=src --cov-report=term-missing

# 只运行未覆盖的测试
pytest --cov --cov-fail-under=80
```

**覆盖率输出示例**：
```
Name                    Stmts   Miss  Cover   Missing
------------------------------------------------------
src/user_service.py        50      5    90%    45,46,47
src/order_service.py       80     20    75%    12-15, 30-40
------------------------------------------------------
TOTAL                     500     50    90%
```

---

## 📝 测试命名规范

```python
# 格式
test_<模块>_<场景>_<预期结果>

# 示例
test_user_login_success              # 用户登录成功
test_user_login_invalid_password     # 用户登录-密码错误
test_user_login_user_not_exist       # 用户登录-用户不存在
test_order_create_with_empty_items   # 创建订单-空商品列表
```

---

## ⚠️ 注意事项

1. **覆盖正常和异常**：正常流程和边界错误都要测试
2. **边界条件**：空值、最大值、最小值、特殊字符
3. **Mock 外部依赖**：数据库、API、第三方服务
4. **测试独立性**：不依赖执行顺序
5. **保持测试快速**：单元测试应该在毫秒级完成
6. **定期运行**：确保没有 regression
